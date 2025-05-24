/*****************************************************************************
 *                      ESP32 network-throughput display                     *
 *****************************************************************************/

#include <Arduino.h>
#include <WiFi.h>
#include <WiFiUdp.h>
#include <ArduinoJson.h>
#include <TFT_eSPI.h>

/* ---------- Espressif SOC API headers ---------- */
#include "soc/soc.h"
#include "soc/dport_reg.h"
#include "soc/gpio_reg.h"
#include "soc/io_mux_reg.h"
#include "soc/ledc_reg.h"
#include "soc/ledc_struct.h"
#include "soc/gpio_sig_map.h"

/* ---------- Wi-Fi / UDP conn config ---------- */
static constexpr char     SSID[]      = "PiAP";
static constexpr char     PASSWORD[]  = "wtfiscry";
static constexpr uint16_t UDP_PORT    = 4000;
static constexpr uint16_t MAX_SAMPLES = 128;

/* ---------- GPIO Pins ---------- */
#define BUTTON     23        // Push-button input
#define RGB_LED_R  18        // TX/RX-dependent PWM output
#define RGB_LED_G  19        // TODO
#define RGB_LED_B  21        // TODO

/* ---------- Colour constants ---------- */
static constexpr uint16_t NAVY   = 0x0013;
static constexpr uint16_t GRID   = 0x34B2;
static constexpr uint16_t CYAN   = 0x07FF;
static constexpr uint16_t ORANGE = 0xFD20;
static constexpr uint16_t FRAME  = 0xFFFF;

/* ------------------------------------------------------------------------*
 *                        LOW-LEVEL GPIO HELPERS                           *
 * ------------------------------------------------------------------------*/
static inline void gpio_output_enable(uint8_t pin)
{
	if (pin < 32) {
		REG_WRITE(GPIO_ENABLE_W1TS_REG, 1UL << pin);
	} else {
		REG_WRITE(GPIO_ENABLE1_W1TS_REG, 1UL << (pin - 32));
	}
}

static inline void gpio_write_high(uint8_t pin)
{
	if (pin < 32) {
		REG_WRITE(GPIO_OUT_W1TS_REG, 1UL << pin);
	} else {
		REG_WRITE(GPIO_OUT1_W1TS_REG, 1UL << (pin - 32));
	}
}

static inline void gpio_write_low(uint8_t pin)
{
	if (pin < 32) {
		REG_WRITE(GPIO_OUT_W1TC_REG, 1UL << pin);
	} else {
		REG_WRITE(GPIO_OUT1_W1TC_REG, 1UL << (pin - 32));
	}
}

static inline void gpio_toggle(uint8_t pin)
{
	uint32_t lvl = (pin < 32)
								 ? REG_READ(GPIO_OUT_REG)
								 : REG_READ(GPIO_OUT1_REG);
	if (lvl & (1UL << (pin & 31))) {
		gpio_write_low(pin);
	} else {
		gpio_write_high(pin);
	}
}

static inline bool gpio_read(uint8_t pin)
{
	uint32_t in = (pin < 32)
								? REG_READ(GPIO_IN_REG)
								: REG_READ(GPIO_IN1_REG);
	return (in & (1UL << (pin & 31))) != 0;
}

static void button_pullup()
{
	// Switch the pin function to GPIO
	PIN_FUNC_SELECT(IO_MUX_GPIO23_REG, PIN_FUNC_GPIO);

	// Enable pull-up - Disable pull-down - Enable input
	REG_SET_BIT(IO_MUX_GPIO23_REG, FUN_PU);
	REG_CLR_BIT(IO_MUX_GPIO23_REG, FUN_PD);
	REG_SET_BIT(IO_MUX_GPIO23_REG, FUN_IE);
}

/* --------------------------------------------------------------------------
 * 2. BARE-METAL GPIO LED CONTROLLER (timer0 / channel0 @ ~5 kHz, 8-bit duty)
 * ------------------------------------------------------------------------*/
static void pwm_init(uint8_t pin)
{
	// Enable the LEDC peripheral clock and reset it
	DPORT_SET_PERI_REG_MASK(DPORT_PERIP_CLK_EN_REG,  DPORT_LEDC_CLK_EN);
	DPORT_CLEAR_PERI_REG_MASK(DPORT_PERIP_RST_EN_REG, DPORT_LEDC_RST);

	// Standard ESP32 APB clock-freq is 80MHz
	constexpr uint32_t SRC_CLK = 80000000;
	// Desired PWM freq
	constexpr uint32_t FREQ    = 5000;
	// Width (Resolution) of the duty cycle in bits
	constexpr uint8_t  RES    = 8;
	uint32_t prescale = (SRC_CLK / (FREQ * (1UL << RES))) - 1;

	/* Configure timer0 in high-speed group */
	auto &t0 = LEDC.timer_group[0].timer[0];
	t0.conf.clock_divider   = prescale;
	t0.conf.duty_resolution = RES;
	t0.conf.tick_sel        = 1;	// Use APB clock
	t0.conf.pause           = 0;
	t0.conf.rst             = 1;
	t0.conf.rst             = 0;

	/* Attach channel0 to timer0 */
	auto &ch0 = LEDC.channel_group[0].channel[0];
	ch0.conf0.timer_sel = 0;		// Use timer0
	ch0.conf0.idle_lv   = 0;
	ch0.hpoint.hpoint   = 0;		// PWM phase starts at 0

	/* Route CH0 output through GPIO matrix */
	// Switch the pin function to GPIO
	PIN_FUNC_SELECT(IO_MUX_GPIO18_REG, PIN_FUNC_GPIO);
	// Set the GPIO's pin output to the LEDC's channel0 output
	REG_WRITE(GPIO_FUNC18_OUT_SEL_CFG_REG, LEDC_HS_SIG_OUT0_IDX);

	/* Set the GPIO's pin to output mode */
	gpio_output_enable(pin);
}

static inline void pwm_set_duty(uint8_t duty)
{
	auto &ch = LEDC.channel_group[0].channel[0];

	if (duty) {
		ch.conf0.sig_out_en    = 1;
		ch.duty.duty           = uint32_t(duty) << 4;  // Lower 4 bits should be set to 0
		ch.conf1.duty_start    = 1;
	} else {
		ch.conf0.sig_out_en    = 0;
		ch.conf1.duty_start    = 0;
	}
}

/* ------------------------------------------------------------------------ *
 *                            MAIN LOGIC                                    *
 * ------------------------------------------------------------------------ */
#define MAX_CLIENTS 4

typedef struct {
	String ip;
	String mac;
} client_t;

TFT_eSPI	tft;
WiFiUDP		udp;

enum DisplayMode : uint8_t { MODE_GRAPH = 0, MODE_CLIENTS = 1, MODE_INFO = 2 };
static volatile DisplayMode currentMode = MODE_GRAPH;

struct Sample { uint32_t rx, tx; };
static Sample  ring[MAX_SAMPLES];
static uint16_t head  = 0;
static uint16_t count = 0;

static inline void addSample(uint32_t rx, uint32_t tx)
{
	ring[head] = { rx, tx };
	head = (head + 1) % MAX_SAMPLES;
	if (count < MAX_SAMPLES)
		++count;
}

static inline Sample getSample(uint16_t i)
{
	int idx = int(head) - 1 - i;
	if (idx < 0)
		idx += MAX_SAMPLES;
	return ring[idx];
}

static float yScaleRX = 1.0f;
static float yScaleTX = 1.0f;
static constexpr float yMin   = 0.1f;
static constexpr float yPad   = 1.2f;
static constexpr float yAlpha = 0.15f;

void updateLED(uint32_t rx, uint32_t tx)
{
	uint32_t full = uint32_t(max(yScaleRX, yScaleTX) * 1000000);
	uint8_t duty = (rx + tx >= full)
									? 255
									: (rx + tx) * 255 / full;
	pwm_set_duty(duty);
}

void drawDual()
{
	const uint8_t W     = tft.width();
	const uint8_t H     = tft.height();
	const uint8_t paneH = (H - 12) / 2;
	const uint8_t gap   = 4;
	const uint8_t left  = 6;
	const uint8_t right = W - 2;
	const uint8_t rxTop = 4;
	const uint8_t txTop = rxTop + paneH + gap;

	tft.fillScreen(TFT_DARKCYAN);
	tft.drawRect(left - 2, rxTop - 2, right - left + 4, paneH + 4, FRAME);
	tft.drawRect(left - 2, txTop - 2, right - left + 4, paneH + 4, FRAME);

	// Auto-scale the traces based on the maximum values seen i.e. last MAX_SAMPLES
	uint32_t peakRX = 1, peakTX = 1;
	for (uint16_t i = 0; i < count; ++i) {
		Sample s = getSample(i);
		peakRX = max(peakRX, s.rx);
		peakTX = max(peakTX, s.tx);
	}
	yScaleRX += yAlpha * (max(yMin, peakRX / 1000000.0f * yPad) - yScaleRX);
	yScaleTX += yAlpha * (max(yMin, peakTX / 1000000.0f * yPad) - yScaleTX);

	// Show the current scale for both RX and TX graphs
	tft.setTextDatum(TR_DATUM);
	tft.setTextColor(CYAN, TFT_DARKCYAN);
	tft.drawString(String(yScaleRX, 1) + " Mbps", right - 2, rxTop + 2);
	tft.setTextColor(ORANGE, TFT_DARKCYAN);
	tft.drawString(String(yScaleTX, 1) + " Mbps", right - 2, txTop + 2);

	auto mapY = [&](uint32_t bps, float scale, uint8_t top) {
		float f = (bps / 1000000.0f) / scale;
		if (f > 1)
			f = 1;
		return uint8_t(top + paneH - f * paneH);
	};

	// Axes
	tft.setTextDatum(MR_DATUM);
	for (int mb = 0; mb <= int(yScaleRX + 0.1f); mb += (yScaleRX > 2 ? 2 : 1)) {
		uint8_t y = mapY(mb * 1000000, yScaleRX, rxTop);
		tft.drawLine(left - 2, y, left, y, CYAN);
		tft.setTextColor(CYAN, NAVY);
	}
	for (int mb = 0; mb <= int(yScaleTX + 0.1f); mb += (yScaleTX > 2 ? 2 : 1)) {
		uint8_t y = mapY(mb * 1000000, yScaleTX, txTop);
		tft.drawLine(left - 2, y, left, y, ORANGE);
		tft.setTextColor(ORANGE, NAVY);
	}

	tft.setTextDatum(TL_DATUM);
	tft.setTextColor(CYAN);
	tft.drawString("RX (Mbps)", left, rxTop + 2);
	tft.setTextColor(ORANGE);
	tft.drawString("TX (Mbps)", left, txTop + 2);

	// Grid
	uint8_t totalH = txTop + paneH - rxTop;
	for (int x = left; x <= right; x += 16) {
		tft.drawFastVLine(x, rxTop, totalH, GRID);
	}
	for (int y = rxTop; y <= rxTop + paneH; y += paneH/4) {
		tft.drawFastHLine(left, y, right-left, GRID);
		tft.drawFastHLine(left, y + paneH + gap, right-left, GRID);
	}

	// Traces
	if (count < 2) return;
	int px   = right - 1;
	int pyRX = mapY(getSample(0).rx, yScaleRX, rxTop);
	int pyTX = mapY(getSample(0).tx, yScaleTX, txTop);
	for (uint16_t i = 1; i < count; ++i) {
		int x    = right - 1 - (right-left-1)*i/(MAX_SAMPLES-1);
		Sample s = getSample(i);
		int yRX  = mapY(s.rx, yScaleRX, rxTop);
		int yTX  = mapY(s.tx, yScaleTX, txTop);
		tft.drawLine(px, pyRX, x, yRX, TFT_GREEN);
		tft.drawLine(px, pyTX, x, yTX, ORANGE);
		px = x;
		pyRX = yRX;
		pyTX = yTX;
	}
}

/* Clients list from the Pi's ARP cache */
void drawClients(client_t *clients, size_t count) {
	tft.fillScreen(TFT_GREENYELLOW);
	tft.setTextDatum(TL_DATUM);
	tft.setTextColor(TFT_BROWN, TFT_GREENYELLOW);
	tft.drawString("CLIENTS", 6, 6);

	tft.setTextColor(TFT_BLACK, TFT_GREENYELLOW);
	uint8_t y = 20;
	if (count == 0) {
		tft.drawString("No clients connected", 6, y);
		return;
	}

	// Draw the client list: IP on one line, MAC on the next
	uint8_t mac_ident = 15;
	for (size_t i = 0; i < count && i < MAX_CLIENTS; ++i) {
		// Print IP address
		tft.drawString(clients[i].ip, 6, y);
		y += 10;
		// Print MAC address immediately below
		tft.drawString(clients[i].mac, 6 + mac_ident, y);
		y += 16;  // leave a gap before the next entry
	}
}


void drawInfo(float temp, float uplink_rssi, size_t mem_avail_MB) {
	tft.fillScreen(TFT_RED);
	tft.setTextDatum(TL_DATUM);
	tft.setTextColor(TFT_SILVER);
	tft.drawString("INFO", 6, 6);
	
	tft.setTextColor(TFT_WHITE);
	tft.drawString("Pi CPU temp: " + String(temp, 1) + " C", 6, 20);

	tft.drawString("Uplink RSSI:" + String(uplink_rssi, 1) + "dBm", 6, 30);

	tft.drawString("Free memory: " + String(mem_avail_MB) + " MB", 6, 40);
}

static void connectWiFi()
{
	WiFi.mode(WIFI_STA);
	tft.fillScreen(NAVY);
	tft.setTextColor(TFT_WHITE, NAVY);
	tft.setTextDatum(MC_DATUM);
	tft.drawString("Waiting for ESP32 to", tft.width()/2, tft.height()/2 - 10);
	tft.drawString("connect to PiAP...",     tft.width()/2, tft.height()/2 + 10);

	WiFi.begin(SSID, PASSWORD);
	/* Busy-wait until the ESP is connected to the PiAP */
	while (WiFi.status() != WL_CONNECTED) {
		delay(250);
	}
}

/* Interrupt for the push-down button with .25s debounce */
void IRAM_ATTR buttonISR() {
	static uint32_t last = 0;
	uint32_t now = millis();
	if (now - last > 250) {
		currentMode = DisplayMode((currentMode + 1) % 3);
		last = now;
	}
}

void setup()
{
	Serial.begin(115200);

	// LED setup
	gpio_output_enable(RGB_LED_G);
	gpio_write_low(RGB_LED_G);
	gpio_output_enable(RGB_LED_B);
	gpio_write_low(RGB_LED_B);

	// Button setup
	button_pullup();
	attachInterrupt(BUTTON, buttonISR, FALLING);

	// Init PWM for the red channel of the LED
	pwm_init(RGB_LED_R);

	// Init the LCD
	tft.init();
	tft.setRotation(1);
	tft.fillScreen(NAVY);

	// Connect via Wi-fi and start the UDP conn
	connectWiFi();
	udp.begin(UDP_PORT);
}

void loop()
{
	if (!udp.parsePacket()) return;

	StaticJsonDocument<512> payload;
	if (deserializeJson(payload, udp) != DeserializationError::Ok) return;

	/* Fetch the data from the PiAP */
	uint32_t rx = payload["rx"], tx = payload["tx"];
	
	JsonArray clients_ips = payload["clients"];
	JsonArray clients_macs = payload["macs"];
	if (clients_ips.size() != clients_macs.size()) {
		Serial.println("Error: Mismatched clients array sizes");
		return;
	}
	size_t clients_count = min(clients_ips.size(), (size_t) MAX_CLIENTS);

	static client_t clients[MAX_CLIENTS];
	for (size_t i = 0; i < clients_count; ++i) {
		clients[i].ip  = clients_ips[i].as<String>();
		clients[i].mac = clients_macs[i].as<String>();
	}

	float temp = payload["temp"];
	float uplink_rssi = payload["uplink_rssi"];
	size_t mem_avail_MB = payload["mem_avail_MB"];

	addSample(rx, tx);

	/* Adjust the LED's brightness based on the RX & TX traffic */
	updateLED(rx, tx);

	/* Draw the current mode */
	switch (currentMode) {
		case MODE_GRAPH:
		drawDual();
		break;
		case MODE_CLIENTS:
		drawClients(clients, clients_count);
		break;
		case MODE_INFO:
		drawInfo(temp, uplink_rssi, mem_avail_MB);
		break;
	}
}

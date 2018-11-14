/*
2.31  Delayorama (delayorama, 1402)

Random seed

Controls the random numbers that will be used to stagger the delays and amplitudes if random is turned up on them. Changing this forces the random values to be recalulated.
Input gain (dB)

Controls the gain of the input signal in dB's.
Feedback (%)

Controls the amount of output signal fed back into the input.
Number of taps

Controls the number of taps in the delay.
First delay (s)

The time of the first delay.
Delay range (s)

The time difference between the first and last delay.
Delay change

The scaling factor between one delay and the next.
Delay random (%)

The random factor applied to the delay.
Amplitude change

The scaling factor between one amplitude and the next.
Amplitude random (%)

The random factor applied to the amplitude.
Dry/wet mix

The level of delayed sound mixed into the output.
*/


(
func: {arg in;

	var sig = LADSPA.ar(1, 1402,
		RandSeed.ir(1000),
		\inputgain.kr(0),
		\feedback.kr(30),
		\numtaps.kr(1),
		\firstdelay.kr(1),
		\delayrange.kr(1),
		\delaychange.kr(1),
		\delayrandom.kr(30),
		\ampchange.kr(0.5),
		\amprand.kr(50),
		/*dry/wet*/1,
		in
	);

	sig * \vol.kr(0.dbamp);
},
specs: [
	\inputgain -> [-96, 24, \lin, 0, 0],
	\feedback -> [0, 100, \lin, 0, 30],
	\numtaps -> [2, 128, \lin, 0, 1],
	\firstdelay -> [0, 5, \lin, 0, 1],
	\delayrange -> [0.0001, 6, \lin, 0, 1],
	\delaychange -> [0.2, 5, \lin, 0, 1],
	\delayrandom -> [0, 100, \lin, 0, 30],
	\ampchange -> [0.2, 5, \lin, 0, 0.5],
	\amprand -> [0, 100, \lin, 0, 50]
]
)

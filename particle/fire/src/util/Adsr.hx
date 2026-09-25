package util;

@:publicFields
class Adsr
{
	var attackMs:Float;
	var decayMs:Float;
	var sustainLevel:Float;
	var releaseMs:Float;

	var stage:Stage = Idle;
	var value:Float = 0.0;
	var time:Float = 0.0;
	var releaseFrom:Float = 0.0;

	function new(attackMs:Float, decayMs:Float, sustainLevel:Float, releaseMs:Float)
	{
		this.attackMs = attackMs;
		this.decayMs = decayMs;
		this.sustainLevel = sustainLevel;
		this.releaseMs = releaseMs;
	}

	function gateOn():Void
	{
		stage = Attack;
		time = 0.0;
	}

	function gateOff():Void
	{
		releaseFrom = value;
		stage = Release;
		time = 0.0;
	}

	function step(deltaMs:Float):Float
	{
		time += deltaMs;

		switch (stage)
		{
			case Idle:
				value = 0.0;

			case Attack:
				value = attackMs <= 0 ? 1.0 : time / attackMs;
				if (value >= 1.0)
				{
					value = 1.0;
					stage = Decay;
					time = 0.0;
				}

			case Decay:
				var t = decayMs <= 0 ? 1.0 : time / decayMs;
				value = 1.0 - (1.0 - sustainLevel) * t;
				if (t >= 1.0)
				{
					value = sustainLevel;
					stage = Sustain;
					time = 0.0;
				}

			case Sustain:
				value = sustainLevel;

			case Release:
				var t = releaseMs <= 0 ? 1.0 : time / releaseMs;
				value = releaseFrom * (1.0 - t);
				if (t >= 1.0)
				{
					value = 0.0;
					stage = Idle;
					time = 0.0;
				}
		}

		return value;
	}
}

enum Stage
{
	Idle;
	Attack;
	Decay;
	Sustain;
	Release;
}

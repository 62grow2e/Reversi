//coded by Yota Odaka

// this class return value of process of each easing motions
public class Easing {
	public Easing () {
	}

	public float easeIn(float t, float begin, float end, float duration) {
		t /= duration;
		return end*t*t+begin;
	}

	public float easeOut(float t, float begin, float end, float duration) {
		t /= duration;
		return -end*t*(t-2.0) + begin;
	}

	public float easeInOut(float t, float begin, float end, float duration) {
		t /= duration/2.f;
		if(t < 1)return end/2.0*t*t + begin;
		t--;
		return -end/2.f*(t*(t-2.f)-1.f) + begin;
	}
}

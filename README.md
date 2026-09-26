# Theatre Optical Security Lab

A browser-based research demonstrator for a **projector-independent optical anti-piracy system** for cinema theatres.

The model links theatre geometry, optical propagation, human temporal perception, and camera acquisition so the concept can be explained quantitatively rather than with a static diagram.

> **Status:** simulation / hypothesis-generation tool. Results are model-derived proxies, not measured cinema performance. Any physical prototype using visible or near-infrared emitters requires measured irradiance and photobiological-safety review before occupied-space testing.

## Research question

Can an external optical protection layer create a large separation between:

- **human-view impact** — kept below a perceptual and safety threshold, and
- **camera-capture impact** — increased through rolling-shutter banding, temporal instability, spectral-response differences, and phase-diverse illumination,

while leaving the cinema projector, DCP, media server, and movie file unchanged?

## Cybersecurity framing

The attack bypasses the digital trust boundary by converting protected content to photons and reacquiring it with an unauthorized sensor.

```text
Protected DCP -> Projector -> Screen -> Unauthorized camera -> Pirate digital copy
                               ^
                               |
                      Optical defense layer
```

The project is therefore a **cyber-physical content-protection** study: defend the physical acquisition channel used to reconstruct a digital asset.

## Interactive simulator

Open `index.html` through a local web server. The UI includes:

- top-down theatre geometry,
- existing projector and cinema screen,
- six independently phased protection emitters,
- animated projector and protection-light paths,
- camera position and field of view,
- wavelength-class, frequency, duty-cycle and phase controls,
- rolling-shutter FPS, exposure and sensor-readout controls,
- simplified IR-cut and global-shutter attack models,
- live camera preview with model-generated banding,
- human-view preview,
- live equations and derived values,
- adversarial presets for ordinary and advanced cameras,
- experiment snapshot export.

## Mathematical model

### Emitter waveform

For emitter (i):

```text
P_i(t) = P0_i [1 + m_i s_i(t; f_i, phi_i, D_i)]
```

where (P0_i) is mean optical power, (m_i) modulation depth, (f_i) modulation frequency, (phi_i) phase and (D_i) duty cycle.

### Propagation to a screen patch

```text
E_i,p(t) ~= P_i(t) G_i(theta) / (4 pi r_i,p^2)
```

The web simulator uses normalized optical units. A physical paper must calibrate (P_i), emitter angular intensity and the screen bidirectional reflectance distribution.

### Screen reflection

First-order Lambertian approximation:

```text
L_p(t, lambda) = rho(lambda) E_p(t, lambda) / pi
```

### Rolling-shutter camera

For image row (y):

```text
t_y = t_frame + (y/H) T_readout
```

and the recorded row signal is:

```text
C_y = (1/T_exp) integral[t_y, t_y + T_exp] L(t) dt
```

A rolling-shutter sensor therefore samples different optical phases at different rows. This mechanism is also used constructively in optical-camera communication: rapidly changing LED states that are not consciously perceived can appear as light/dark bands in a smartphone image.

### Human-view proxy

The human-view score is based on visible-spectrum modulation after temporal averaging. NIR channels are strongly down-weighted in the human model. This is only a comparative proxy; real temporal-light-artifact perception depends on waveform, luminance, retinal position, eye movement and observer variability.

## What is genuinely being tested

The project is **not** testing whether one fixed flicker frequency can block every camera.

It tests whether diversity can make simple bypasses less effective:

```text
spectral diversity
+ temporal diversity
+ spatial diversity
+ phase diversity
+ controlled randomization
--------------------------------
camera-acquisition difficulty
```

## Threat model

The attacker may try:

- strong IR-cut filtering,
- manual exposure,
- high frame rate,
- exposure synchronization / anti-flicker settings,
- different phone sensors,
- landscape/portrait orientation,
- temporal averaging,
- a global-shutter camera.

The simulator exposes these as camera presets so the defense can be red-teamed instead of only demonstrated under favorable settings.

## Success criteria

A physical study should report a **Pareto frontier**, not a binary “works / does not work” claim:

1. viewer-visible modulation or discomfort proxy,
2. camera degradation (banding, frame instability, color error, SSIM/PSNR or task-specific metrics),
3. optical power / exposure,
4. camera-model coverage,
5. robustness after attacker countermeasures.

## Literature anchors

- Danakis et al., “Using a CMOS camera sensor for visible light communication,” IEEE GLOBECOM Workshops, 2012, DOI: 10.1109/GLOCOMW.2012.6477759. Demonstrates rolling-shutter capture of LED changes as bands.
- Wang et al., “Investigation into preventing piracy based on the temporal perception difference between devices and humans using modulated projection light,” *Displays*, 88, 102995, 2025, DOI: 10.1016/j.displa.2025.102995. Uses spatial/temporal projection-light modulation and frequency randomization for anti-piracy.
- U.S. DOE/PNNL, “Flicker: A review of temporal light modulation stimulus, responses, and measures.” Reviews temporal-light artifacts and limitations of simple flicker thresholds.
- IEEE 1789-2015, recommended practice for LED current modulation and health-risk mitigation.
- IEC 62471:2006, photobiological safety of lamps and lamp systems, covering broadband optical sources including LEDs from 200–3000 nm.

## Experimental roadmap

### Stage A — measured bench optics
- one projector,
- small matte screen,
- low-power visible and NIR channels,
- photodiode + oscilloscope,
- two or more smartphones,
- measured optical waveform and camera response.

### Stage B — camera diversity
Test 24/30/60/120/240 fps, auto/manual exposure, orientation, multiple phone vendors, strong IR-cut filtering and a global-shutter reference camera.

### Stage C — phase-diverse array
Drive emitters independently with deliberate phase offsets and test whether one exposure configuration suppresses all spatial regions simultaneously.

### Stage D — adversarial evaluation
Red-team with optical filtering, exposure synchronization, temporal averaging, cropping, denoising, high-FPS capture and global shutter.

### Stage E — human factors and safety
Only after low-power bench validation: calibrated irradiance, IEC 62471-aligned photobiological review, temporal-light-artifact assessment and controlled observer testing.

## Run locally

```bash
git clone https://github.com/Saitanveesh/Theather.git
cd Theather
git checkout research-simulator-v1
python -m http.server 8000
```

Open `http://localhost:8000`.

## Design principle

```text
DEGRADE casual capture + INCREASE attacker effort + RETAIN optional traceability
```

The security objective is measurable acquisition difficulty with acceptable viewer impact — not a claim that every conceivable camera can be made unusable.

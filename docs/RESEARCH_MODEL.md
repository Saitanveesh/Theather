# Research Model and Experimental Protocol

## 1. System boundary

The proposed system is intentionally external to the cinema playback chain.

```text
DCP / media server
       |
       v
existing projector --------------------+
       |                                |
       v                                |
cinema screen <--- optical defense -----+
       |
       +----> human visual system
       |
       +----> unauthorized camera -> reconstructed digital copy
```

No claim of novelty is made merely from “using IR,” “using flicker,” “adding a second projector,” or “using a retrofit device.” Those concepts have substantial prior art. The research value must come from the measured behavior of a specific adaptive, spatially and temporally diverse defense under an explicit adversarial camera model.

---

## 2. Coordinate model

Use a right-handed theatre coordinate system:

- screen plane: (x = 0),
- auditorium: (x > 0),
- horizontal screen coordinate: (y),
- vertical coordinate: (z).

For protection emitter (i), screen sample (p), and camera (c):

```text
r_i,p = ||x_i - x_p||
r_p,c = ||x_p - x_c||
r_total = r_i,p + r_p,c
tau_i,p,c = r_total / c
```

where (c = 299,792,458) m/s.

Optical time of flight is only tens to hundreds of nanoseconds over theatre-scale paths. It is therefore *not* the useful source of anti-camera phase diversity. The useful phase diversity is deliberately introduced electronically in the emitter waveform.

That distinction is important: the simulator displays time of flight for physical completeness but does not pretend theatre propagation delay is large enough to create the effect by itself.

---

## 3. Emitter model

Emitter (i) is defined by:

```text
theta_i = {position, wavelength, P0, f, m, D, phi}
```

with:

- (P_0): mean radiant/optical power,
- (f): modulation frequency,
- (m): modulation depth,
- (D): duty cycle,
- (phi): phase.

A normalized square-wave representation is:

```text
P_i(t) = P0_i [1 + m_i s_i(t)]
```

The real prototype should record the actual waveform using a photodiode and oscilloscope because the electrical PWM command is not necessarily equal to emitted optical power. LED driver rise/fall time, current limiting, thermal droop and controller jitter must be measured.

---

## 4. Propagation model

A first-order free-space model is:

```text
E_i,p(t,lambda) =
P_i(t,lambda) * G_i(theta_i,p) / (4 pi r_i,p^2)
```

where (G_i) is the measured/angular emitter gain.

For the browser demonstration, (G_i) is simplified and values are normalized.

For a physical publication, replace this with either:

1. measured irradiance maps across the screen, or
2. calibrated emitter radiant intensity (I_e(theta,lambda)).

---

## 5. Screen model

The current simulator starts with a Lambertian approximation:

```text
L_p(t,lambda) = rho_p(lambda) E_p(t,lambda) / pi
```

This assumption is intentionally visible in the documentation because real cinema screens are not perfect Lambertian reflectors. Gain screens and perforated screens may have directional behavior.

A stronger experimental model uses a wavelength-dependent BRDF:

```text
L_r(theta_r,phi_r,lambda) =
f_r(theta_i,phi_i,theta_r,phi_r,lambda) E_i
```

### Measurement requirement

For every screen material under test:

- visible reflectance,
- 850 nm reflectance,
- 940 nm reflectance,
- angular response toward representative audience positions.

This determines whether NIR survives the screen path strongly enough to matter.

---

## 6. Camera sampling model

### Rolling shutter

A rolling-shutter sensor exposes different rows at different times.

For image row (y):

```text
t_y = t_0 + y/H * T_readout
```

The recorded row is an exposure integral:

```text
C_y =
1/T_exp *
integral[t_y, t_y + T_exp]
S(lambda) T_IR(lambda) L(t,lambda) dt d(lambda)
```

where:

- (S(lambda)) = sensor spectral response,
- (T_IR(lambda)) = optical-stack / IR-cut transmission,
- (T_exp) = exposure duration,
- (T_readout) = frame readout duration.

### Why bands appear

The phase advance from first to last row is:

```text
Delta_phi_readout = 2 pi f T_readout
```

An intuitive first-order estimate of modulation cycles across a frame is:

```text
N_bands ~ f T_readout
```

The exact visible band count depends on waveform, exposure integration, demosaicing, ISP processing and aliasing.

### Exposure averaging

For a sinusoidal component, exposure integration attenuates the modulation approximately by:

```text
A_exp = |sinc(f T_exp)|
      = |sin(pi f T_exp) / (pi f T_exp)|
```

This immediately explains an attacker strategy: choose an exposure duration close to an integer number of modulation periods and a single-frequency signal can average toward its mean.

That is why a credible defense must be evaluated against exposure synchronization rather than demonstrated at one favorable setting.

---

## 7. Human-view model

The human visual system is not a frame camera.

The browser uses a simple low-pass proxy:

```text
H(f) = 1 / sqrt(1 + (f/f_c)^2)
```

and strongly suppresses NIR contribution.

This is **not** a claim of perceptual invisibility.

Real temporal-light-artifact visibility depends on:

- luminance,
- modulation depth,
- waveform,
- duty cycle,
- retinal eccentricity,
- eye motion,
- spatial extent,
- individual observer.

The DOE/PNNL flicker review notes that simple frequency thresholds are inadequate for all temporal-light artifacts, and IEEE 1789 itself is not a universal perceptual boundary.

Therefore the physical research must use a human-factors protocol rather than “frequency > X means invisible.”

---

## 8. Security threat model

### Protected asset

High-value theatrical audiovisual content.

### Attack objective

Acquire a usable digital recording from the physical projection.

### Attacker controls

Assume the attacker can vary:

```text
camera model
sensor technology
orientation
frame rate
exposure time
ISO / gain
focus
HDR mode
anti-flicker mode
IR-cut / optical filters
post-processing
temporal averaging
cropping
denoising
```

A stronger attacker may use a global-shutter camera.

### Defender controls

```text
emitter position
wavelength class
modulation frequency
duty cycle
phase
modulation depth
spatial distribution
temporal sequence
optional forensic payload
```

---

## 9. Research hypotheses

### H1 — human/camera separability

There exists a parameter region in which camera degradation increases materially while measured viewer-visible disturbance remains below an accepted experimental threshold.

**Falsifier:** no such region exists once realistic brightness and safety constraints are applied.

### H2 — phase diversity

Independent emitter phase offsets reduce the probability that one exposure configuration suppresses modulation across all protected spatial regions.

**Falsifier:** phase diversity produces no statistically meaningful robustness increase after controlling for total optical power.

### H3 — spectral diversity

Combining visible-edge and NIR channels provides greater robustness across heterogeneous cameras than a single NIR wavelength at equal safe exposure.

**Falsifier:** camera IR-cut diversity or screen reflectance makes the NIR channel contribute negligibly.

### H4 — randomization

Bounded frequency/phase randomization reduces the effectiveness of exposure synchronization compared with a fixed-frequency defense.

**Falsifier:** attacker-side temporal filtering or exposure adaptation removes the randomized effect with minimal reconstruction loss.

### H5 — global-shutter limit

A defense dominated by rolling-shutter artifacts loses substantial effectiveness against global-shutter acquisition.

This is intentionally expected to be true. A good security paper should document the boundary rather than hide it.

---

## 10. Primary metrics

Do not use one subjective “looks bad” score for the paper.

### Camera-side metrics

- SSIM relative to a reference capture,
- PSNR,
- LPIPS or another perceptual metric if appropriate,
- temporal luminance variance,
- banding energy in the spatial-frequency spectrum,
- color error / Delta E,
- OCR / face / object-task degradation if a downstream task is relevant,
- percentage of frames passing a defined “usable piracy frame” criterion.

### Viewer-side metrics

- measured visible-light modulation,
- temporal-light-artifact metric selected from lighting literature,
- luminance difference,
- chromaticity difference,
- observer rating in a controlled study,
- adverse-event / discomfort reporting.

### Safety metrics

- spectral irradiance,
- radiance where applicable,
- exposure duration,
- IEC 62471 hazard evaluation by wavelength and geometry.

### Security metric

Report a Pareto frontier:

```text
maximize camera degradation
subject to:
    viewer impact <= threshold
    optical exposure <= safety limit
```

This is scientifically stronger than claiming a single “best frequency.”

---

## 11. Experimental design

### Stage 0 — timing characterization

Equipment:

- MCU/FPGA emitter controller,
- photodiode,
- oscilloscope.

Measure:

- requested PWM frequency,
- actual optical frequency,
- duty cycle,
- rise/fall time,
- timing jitter,
- phase error between channels.

Acceptance criterion:

The emitted waveform, not firmware configuration, is the source of truth.

### Stage 1 — one-emitter camera characterization

Independent variables:

```text
frequency
modulation depth
duty cycle
wavelength
camera FPS
exposure
orientation
distance
```

Output:

A response surface rather than a cherry-picked screenshot.

### Stage 2 — multi-emitter phase diversity

Compare:

```text
A: all emitters phase-aligned
B: deterministic phase spread
C: bounded time-varying phase schedule
```

Hold mean optical power constant.

This control is necessary to show that any improvement comes from phase diversity rather than simply adding more light.

### Stage 3 — adversarial bypass

Attacker experiments:

- exposure matched to modulation period,
- high FPS,
- strong IR-cut filter,
- temporal median/mean filtering,
- frame selection,
- global shutter.

Record the exact configuration that produces the **best attacker result**, not only the defender's best result.

### Stage 4 — heterogeneous devices

Use phones from multiple vendors and price tiers.

Do not generalize from one iPhone/Android model.

### Stage 5 — human study

Only after optical safety review.

Use randomized A/B presentation:

```text
A = baseline movie
B = protection enabled
```

Blind the participant to condition where practical.

Collect:

- detection of difference,
- comfort,
- flicker/visual artifact report,
- viewing-quality rating.

---

## 12. Adversarial sweep in the web simulator

The simulator searches a grid over:

- FPS,
- exposure,
- readout time,
- IR rejection.

For each configuration it computes the current model's degradation proxy and reports:

- mean score,
- fraction above a threshold,
- worst configuration,
- a global-shutter reference.

The point is methodological: **always expose the worst case.**

The threshold in the UI is not a scientific standard. It exists only to make design comparisons visible.

---

## 13. What must be measured before publication

Replace every normalized term below:

| Simulation term | Physical replacement |
|---|---|
| emitter power | calibrated radiant intensity / irradiance |
| inverse-square gain | measured angular emitter profile |
| screen reflectance | spectral reflectance / BRDF |
| camera spectral gain | measured or characterized sensor + filter response |
| readout time | measured camera row timing |
| human low-pass proxy | validated perceptual metric / observer study |
| degradation proxy | SSIM/PSNR/banding/color/task metrics |
| safety statement | IEC 62471-aligned evaluation |

---

## 14. Literature anchors

1. Danakis et al., **Using a CMOS camera sensor for visible light communication**, IEEE GLOBECOM Workshops, 2012. DOI: 10.1109/GLOCOMW.2012.6477759.
2. Wang et al., **Investigation into preventing piracy based on the temporal perception difference between devices and humans using modulated projection light**, *Displays* 88 (2025) 102995. DOI: 10.1016/j.displa.2025.102995.
3. U.S. DOE / PNNL, **Flicker: A review of temporal light modulation stimulus, responses, and measures**.
4. IEEE 1789-2015, **Recommended Practices for Modulating Current in High-Brightness LEDs for Mitigating Health Risks to Viewers**.
5. IEC 62471:2006, **Photobiological safety of lamps and lamp systems**.

---

## 15. Research standard

A strong result is not:

> “Our phone showed purple bands.”

A strong result is:

> “Across a preregistered camera/exposure test matrix, the phase-diverse defense shifted the camera-quality distribution by X while maintaining viewer metric Y and measured optical exposure Z; the strongest bypass was configuration Q, which reduced the effect by R.”

That is the standard this repository is intended to support.

# Bench Measurement Guide

This guide converts the browser simulator into a measured research workflow.

## 1. Minimum bench setup

Use a small controlled setup first:

- existing projector or bright display,
- matte white screen,
- low-power visible LED channel,
- low-power NIR LED channel,
- microcontroller / FPGA waveform generator,
- LED driver,
- photodiode,
- oscilloscope,
- lux meter,
- at least two smartphones,
- tripods,
- measuring tape.

Do not move to high optical powers or occupied-theatre testing until spectral irradiance and photobiological exposure are characterized.

---

## 2. What must be recorded for every experiment

Each row in `data/experiment_template.csv` represents one camera capture condition.

### Geometry
- camera distance from screen,
- camera angle,
- emitter position,
- screen material.

### Optical drive
- wavelength,
- modulation frequency,
- duty cycle,
- modulation depth,
- phase spread.

### Measured optical quantities
- actual optical waveform from photodiode,
- irradiance at the relevant location,
- visible lux where applicable.

### Camera configuration
- camera model,
- sensor type if known,
- frame rate,
- exposure time,
- measured/estimated readout time,
- orientation,
- IR-cut / optical filter configuration.

### Result metrics
- SSIM,
- PSNR,
- banding-energy metric,
- color error ΔE,
- viewer-impact score only after an approved human-factor protocol.

---

## 3. Photodiode timing measurement

Connect the photodiode output to an oscilloscope.

Measure:

1. actual optical frequency,
2. duty cycle,
3. rise time,
4. fall time,
5. inter-channel phase difference,
6. timing jitter.

Do not trust MCU PWM configuration as the optical ground truth.

For each channel record:

```text
requested frequency
measured optical frequency
requested phase
measured phase
requested duty
measured duty
peak detector voltage
mean detector voltage
```

The detector voltage must later be calibrated to optical power if quantitative irradiance is required.

---

## 4. Camera reference capture

For each camera condition acquire:

### Reference
Protection emitters OFF.

### Protected
Protection emitters ON.

Keep:

- projector content,
- camera position,
- camera settings,
- ambient light

unchanged between the pair.

The pair is what allows objective image/video quality comparison.

---

## 5. First experiment matrix

Start small.

### Frequencies
```text
120 Hz
240 Hz
480 Hz
720 Hz
1000 Hz
1500 Hz
2000 Hz
```

### Camera frame rates
```text
30 fps
60 fps
120 fps
```

### Exposure times
```text
1 ms
2 ms
4 ms
8 ms
16 ms
```

### Optical channels
```text
visible-only
850 nm NIR
940 nm NIR
hybrid
```

Do not run the full Cartesian product initially. Characterize one camera and one emitter first, then expand around regions that show useful separation.

---

## 6. Phase-diversity experiment

Once one-emitter characterization is stable, use multiple channels.

Compare three conditions at equal mean optical power:

```text
A: phase aligned
B: fixed phase spread
C: bounded time-varying phase schedule
```

This control matters. Otherwise an apparent improvement might simply come from using more total light.

---

## 7. Measuring readout time

Camera rolling-shutter readout time is often not exposed by the phone API.

A practical characterization method is to image a precisely modulated light source with known frequency and infer line timing from the observed stripe spacing.

Document the derivation and uncertainty.

Do not silently substitute frame duration for sensor readout time; they are not generally identical.

---

## 8. Image/video quality analysis

The dashboard accepts these fields:

### SSIM
Similarity to the reference capture.

```text
1.0 = nearly identical
lower = more structural degradation
```

The dashboard displays:

```text
measured degradation = 100 × (1 - SSIM)
```

This is only a visualization transform, not a universal piracy-quality metric.

### PSNR
Report separately.

### Banding energy
A useful custom metric can be based on power in horizontal/vertical spatial-frequency components after subtracting the reference.

### ΔE
Use for color distortion where a calibrated color workflow is available.

---

## 9. File naming

Use deterministic names:

```text
EXP001_PHONEA_30FPS_8MS_720HZ_REF.mp4
EXP001_PHONEA_30FPS_8MS_720HZ_PROTECTED.mp4
EXP001_SCOPE.csv
EXP001_METADATA.json
```

This prevents later ambiguity.

---

## 10. Dashboard workflow

1. Fill measured rows in `data/experiment_template.csv`.
2. Save a copy, for example `data/bench_2026_09_26.csv`.
3. Start the local server.
4. Open `measurement-dashboard.html`.
5. Click **Load CSV**.
6. Select the measured dataset.
7. Inspect:
   - mean degradation,
   - viewer impact,
   - model mean absolute error,
   - measured-vs-model scatter,
   - Pareto plot,
   - raw experiment ledger.

A high model error is not automatically bad. It tells us the simplified theory is missing an important camera, screen, or optical term.

---

## 11. PowerShell

From the repository folder:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\run.ps1
```

The launcher starts a local Python HTTP server at port 8000 and opens both dashboards.

If Python is installed only through the Windows launcher, use:

```powershell
py -m http.server 8000
```

Then open:

```text
http://localhost:8000/
http://localhost:8000/measurement-dashboard.html
```

# Asset Guidelines (Triangle Budgets & Pipeline)

These rules keep GodotMark playable on ARM boards (RPi 4 GPU budget ≈ **10k triangles** for 60 FPS). Stay low‑poly and test before submitting.

## 1. Why Triangle Count Matters on ARM
- Raspberry Pi 4/5 GPUs handle ~10k tris at 60 FPS for the whole scene.
- Budget per asset type:
  - Trees: **< 500 tris**
  - Vegetation (grass/flowers): **< 200 tris**
  - Rocks/props: **< 100 tris**
  - Characters/hero objects: keep as low as visually acceptable; aim **< 1k**.

## 2. How to Check Triangle Count
- **Blender**: Scene Statistics (top-right overlay) → **Tris**.
- **Godot Editor**: Select MeshInstance → **Mesh** → “Primitives” shows triangles/vertices.
- **CLI**: Exported GLB → `gltf-transform inspect <file.glb>` (shows triangle counts).

## 3. The “1k” Naming Trap
- On PolyHaven, “1k” means **1k texture resolution**, **not** 1k triangles.
- Photogrammetry assets there routinely exceed 500k tris — **don’t use them**.

## 4. Approved Asset Sources
- **Kenney.nl** (CC0, reliably low‑poly)
- **OpenGameArt.org** (check license per asset; prefer CC0/CC-BY)
- **Custom Blender creations** sized to the budgets above
- If unsure, ask in Discussions before investing time.

## 5. Per‑Asset Triangle Limits (hard caps)
- Trees: **< 500**
- Vegetation: **< 200**
- Rocks: **< 100**
- Other props: keep within total scene budget (~10k) and document counts in PR.

## 6. How to Test Before Submitting
1. Drop the mesh into the existing scene.
2. In Godot, check **RenderingServer → Primitives** to confirm total tris stay near/under 10k.
3. Run on desktop; if possible, test on Raspberry Pi/ARM. Note FPS and primitives count in your PR.
4. If over budget, decimate/remesh until it fits.

Following these steps prevents accidental heavy assets and keeps benchmarks valid on ARM hardware.

# Deterministic Score-based Diffusion Model for Channel Estimation in RIS-assisted MIMO Systems

This repository provides the source code for the paper:

**"Deterministic Score-based Diffusion Model for Channel Estimation in RIS-assisted MIMO Systems"**

> 📝 Note: While this work was ultimately published as a **conference paper**, the original version was developed for a **journal submission**. Therefore, some parts of the code—particularly the **network architecture** and **deterministic diffusion design**—may be more complex or exploratory than the simplified version in the publication.

---

## 📌 Overview

This project proposes a novel **deterministic score-based diffusion model** for accurate CSI estimation in RIS-assisted MIMO systems. It leverages the structural properties of wireless channels and removes the need for sampling-based inference common in traditional diffusion models.

---

## 🛰️ Channel Generation

This project **includes** a channel generator module under `channel_generator/`, which allows you to synthesize RIS-assisted MIMO CSI datasets.

However, **you must run the channel generator yourself** before training or evaluation. No pre-generated CSI is provided due to space and reproducibility constraints.

To generate CSI:

```bash
python channel_generator/generate_csi.py --config configs/your_config.yaml
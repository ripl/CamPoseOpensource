<p align="center">
  <h1 align="center">Do You Know Where Your Camera Is? View-Invariant Policy Learning with Camera Conditioning </h1>
  <p align="center">
    Tianchong Jiang<sup>1</sup>,
    Jingtian Ji<sup>1</sup>,
    Xiangshan Tan<sup>1</sup>,
    Jiading Fang<sup>2,*</sup>,
    Anand Bhattad<sup>3</sup>,
    Vitor Guizilini<sup>4,†</sup>,
    Matthew R. Walter<sup>1,†</sup>
  </p>
  <p align="center">
    <sup>1</sup>TTIC &nbsp; <sup>2</sup>Waymo &nbsp; <sup>3</sup>Johns Hopkins University &nbsp; <sup>4</sup>Toyota Research Institute
  </p>
  <p align="center">
    <a href='https://arxiv.org/abs/2510.02268'>
      <img src='https://img.shields.io/badge/Paper-PDF-red?style=flat&logo=arXiv&logoColor=red' alt='Paper PDF'>
    </a>
    <a href='https://ripl.github.io/know_your_camera' style='padding-left: 0.5rem;'>
      <img src='https://img.shields.io/badge/Project-Page-blue?style=flat&logo=Google%20chrome&logoColor=blue' alt='Project Page'>
    </a>
  </p>
  <p align="center">
    <strong>Accepted to ICRA 2026</strong> (Vienna, June 2026)<br>
    <strong>Best Paper Award on Robot Learning</strong>
  </p>
</p>

---

## Installation

First, clone the repo and cd into it.
```sh
git clone https://github.com/ripl/CamPoseOpensource
cd CamPoseOpensource
```

Then, setup the Pixi environment and download data.

```sh
pixi run setup
```

Activate the Pixi environment with

```sh
pixi shell -e robosuite # Only Robosuite
pixi shell -e maniskill # Only ManiSkill
pixi shell # All environments
```

---

## Run Training

You can run training in robosuite with
```
python policy_robosuite/train.py
```
or in ManiSkill with
```
python policy_maniskill/train.py
```

---

## Reproduce Paper Results

Every experiment in the paper is specified in [`reproduce/paper_runs.yaml`](reproduce/paper_runs.yaml), keyed by figure (e.g. `fig6`) and entry. To launch one run, pass the figure, entry, and seed:
```
python reproduce/reproduce.py --paper_item fig6 --exp lift_randomized_with_conditioning --seed 0
```
This invokes the matching `train.py` with the exact overrides and seed used for the paper.

If you use a coding agent (Cursor, Claude Code, Codex, etc.), you can point it at [`reproduce/SKILL.md`](reproduce/SKILL.md) and just say e.g. "reproduce fig 6 lift randomized with conditioning" — it will ask about your scheduler and draft a job script. I honestly don't know how well this works in practice yet.

Results will not be bitwise identical across machines — this is not guaranteed on modern GPUs (see [this blog](https://thinkingmachines.ai/blog/defeating-nondeterminism-in-llm-inference/) for background) — but numbers should match the paper in expectation. **If something looks off, or you hit any other issue, I'd really appreciate hearing about it — please open an issue or email `tianchongj [at] ttic [dot] edu`.**

Training runs are long (typically hours to a day per seed on one GPU), so in practice you'll want a cluster (SLURM or similar).

---

## Plücker Snippet

To add camera conditioning to your policy, you can use the following minimalist snippet to get Plücker raymap from intrinsics and extrinsics. (It assumes OpenCV convention i.e. image origin at top-left, +z is forward.)
```
import torch

def get_plucker_raymap(K, c2w, height, width):
    """intrinsics (3,3), cam2world (4,4), height int, width int"""
    vv, uu = torch.meshgrid(
        torch.arange(height, device=K.device, dtype=K.dtype) + 0.5,
        torch.arange(width, device=K.device, dtype=K.dtype) + 0.5,
        indexing="ij",
    )
    rays = torch.stack([uu, vv, torch.ones_like(uu)], dim=-1)
    d_world = torch.nn.functional.normalize(
        (rays @ torch.linalg.inv(K).T) @ c2w[:3, :3].T,
        dim=-1,
        eps=1e-9,
    )
    o = c2w[:3, 3].view(1, 1, 3)
    m = torch.cross(o, d_world, dim=-1)
    return torch.cat([d_world, m], dim=-1)
```


---

## BibTeX

If you find this work useful, please cite:
```
@inproceedings{jiang2026knowyourcamera,
  title     = {Do You Know Where Your Camera Is? {V}iew-Invariant Policy Learning with Camera Conditioning},
  author    = {Tianchong Jiang and Jingtian Ji and Xiangshan Tan and Jiading Fang and Anand Bhattad and Vitor Guizilini and Matthew R. Walter},
  booktitle = {IEEE International Conference on Robotics and Automation (ICRA)},
  year      = {2026},
}
```

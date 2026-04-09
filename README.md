# OpenGraph Workshop

A hands-on workshop for learning [BloodHound](https://github.com/SpecterOps/BloodHound) OpenGraph — a framework for connecting multiple data sources into a unified graph for analysis.

## Prerequisites

- Docker ([Engine](https://docs.docker.com/engine/install/) on Linux, [Desktop](https://docs.docker.com/desktop/) on macOS/Windows)
- BloodHound Community Edition with OpenGraph enabled (see [install-bloodhound/](install-bloodhound/))

## Repository Structure

```
OpenGraphWorkshop/
├── install-bloodhound/   # Automated BloodHound CE + OpenGraph install scripts
├── lab1/                 # Lab 1: OpenGraph fundamentals (nodes, edges, schemas)
└── lab2/                 # Lab 2: Real-world data collection
    ├── 0_collecting-an-edge/    # Single repo contributor graph
    ├── 1_expanding-the-graph/   # Multi-repo organization graph
    └── 2_hybrid-edges/          # Cross-source GitHub + X (Twitter) graph
```

## Getting Started

1. Install BloodHound CE with OpenGraph using the scripts in [install-bloodhound/](install-bloodhound/)
2. Work through the labs in order:
   - **[Lab 1](lab1/)** — Build a simple social graph to learn core OpenGraph concepts (schemas, nodes, edges, cypher queries)
   - **[Lab 2.0](lab2/0_collecting-an-edge/)** — Collect GitHub contributors for a single repository
   - **[Lab 2.1](lab2/1_expanding-the-graph/)** — Expand the graph across multiple repositories in an organization
   - **[Lab 2.2](lab2/2_hybrid-edges/)** — Link GitHub users to X (Twitter) profiles with cross-source hybrid edges

Each lab includes pre-collected sample data so you can follow along without making API calls.

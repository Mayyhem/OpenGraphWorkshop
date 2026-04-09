# OpenGraph Workshop

A hands-on workshop for learning [BloodHound OpenGraph](https://specterops.io/opengraph/) — a framework for connecting multiple data sources into a unified graph for analysis.

This repository is a complement to the Build Your Own OpenGraph Collector Workshop presented at [SO-CON 2026](https://specterops.io/so-con/) by Mat Soulnier ([@Scoubi](https://x.com/ScoubiMtl)) and Chris Thompson ([@_Mayyhem](https://x.com/_Mayyhem)).

## Prerequisites

- Docker ([Engine](https://docs.docker.com/engine/install/) on Linux, [Desktop](https://docs.docker.com/desktop/) on macOS/Windows)
- BloodHound Community Edition with OpenGraph enabled (see [install-bloodhound/](install-bloodhound/))

## Repository Structure

```
OpenGraphWorkshop/
├── install-bloodhound/          # Automated BloodHound CE + OpenGraph install scripts
├── lab1/                        # Lab 1: OpenGraph fundamentals (nodes, edges, schemas)
└── lab2/                        # Lab 2: Real-world data collection
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

## Resources
- https://bloodhound.specterops.io/opengraph/developer
- https://bloodhound.specterops.io/opengraph/developer/graph-theory


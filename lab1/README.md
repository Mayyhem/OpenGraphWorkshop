# Lab 1: OpenGraph Fundamentals

Build a simple social graph with two people (Bob and Alice) to learn core OpenGraph concepts.

## Concepts

- **Schema** — Defines node kinds (e.g., `OG_Person`) and relationship kinds (e.g., `OG_Knows`)
- **Nodes** — Entities in the graph (Bob, Alice)
- **Edges** — Relationships between nodes (Bob knows Alice)
- **Cypher queries** — Graph query language for finding patterns

## Files

| File | Description |
|------|-------------|
| `schema_OG.json` | Schema defining `OG_Person` nodes and `OG_Knows` relationships |
| `custom-icon_OG_Person.json` | Custom Font Awesome icon for the `OG_Person` node kind |
| `collected_data_OG_bob-and-alice.json` | Sample data: Bob and Alice with bidirectional "knows" edges |
| `cypher_query_1_Everyone Who Knows Anyone.json` | Find all "knows" relationships |
| `cypher_query_2_Everyone Bob Knows.json` | Find everyone Bob knows |
| `cypher_query_3_Everyone Who Knows Bob.json` | Find everyone who knows Bob |

## Steps

1. 
    a. **Upload the schema** — In BloodHound, navigate to `Administration > OpenGraph Management` and upload `schema_OG.json` 
  
    OR 

    b. **Upload the custom icon** — In BloodHound, navigate to `Administration > API Explorer`, type `custom-nodes`, select `POST /api/v2/custom-nodes`, click `Try it out`, paste `custom-icon_OG_Person.json`, then click `Execute` to set the icon for `OG_Person` nodes

2. **Upload the collected data** — In BloodHound, navigate to `Quick Upload`, then upload `collected_data_OG_bob-and-alice.json` to populate the graph

3. **Run cypher queries** — In BloodHound, navigate to `Explore > Cypher` and either:
    
    a. Paste each of the three cypher queries and click `Run` to explore the graph:

    Everyone Who Knows Anyone:
    ```
    MATCH p = ()-[:OG_Knows]-() 
    RETURN p
    ```
    Everyone Bob Knows:
    ```
    MATCH p = (b)-[:OG_Knows]->(a)
    WHERE b.name = "BOB"
    RETURN p
    ```
    Everyone Who Knows Bob:
    ```
    MATCH p = (b)<-[:OG_Knows]-(a)
    WHERE b.name = "BOB"
    RETURN p
    ```
    
    OR
    
    b. Navigate to `Saved Queries`, click `Import`, and select and upload the `cypher_query*` files. Then, navigate to `Source > Personal` to try each of the three cypher queries to explore the graph.

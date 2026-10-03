# AWS E-Commerce Data Engineering Pipeline

## Project Overview
This project is built from scratch with a heavy focus on **AWS cloud services** to design a complete, production-ready data pipeline. It handles real-time data ingestion via custom API endpoints, processes distributed data using PySpark, stores information across structured cloud storage zones, and serves fast serverless analytics directly on AWS.

---

## Architecture 

<img width="2081" height="1732" alt="aws project final arc" src="https://github.com/user-attachments/assets/3b4d8c67-b590-45fe-a7c6-c3a6ab36ca56" />

---
### Detailed Flow :
1. **Cloud Ingestion & Real-Time Layer:**
   - **Python Data Generator & FastAPI:** Generates and serves simulated e-commerce events locally.
   - **ngrok:** Bridges local environments to the cloud securely via tunneling.
   - **AWS Lambda:** Captures incoming payloads serverlessly and writes them straight into the **Amazon S3 Raw Zone**.
2. **Cloud Storage & Medallion Architecture (Amazon S3):**
   - **Raw Zone:** Stores initial immutable ingested files.
   - **Processed/Curated Zone:** Holds clean, optimized Parquet datasets.
3. **Transformation Layer (PySpark):**
   - Processes and models relational data into a clean **Star Schema**.
4. **AWS Analytics Stack:**
   - **AWS Glue Crawler:** Automatically discovers schemas and populates the **AWS Glue Data Catalog**.
   - **Amazon Athena:** Executes fast, serverless SQL queries on top of the S3 curated data.

---

## Data Engineering Best Practices & Optimizations
The pipeline incorporates core engineering patterns to ensure efficiency and scalability:
- **State Management & Checkpointing:** Tracks stream states precisely to avoid duplicates.
- **Incremental Processing & Batching:** Processes micro-batches instead of full re-loads to save compute time.
- **Schema Evolution:** Handles structural changes smoothly without breaking down-stream layers.
- **Partitioning & Columnar Storage:** Saves curated data in **Parquet format** partitioned by keys like `Country` and `OrderDate` to heavily optimize Amazon Athena query costs and speeds.

---

## Star Schema & Data Modeling (Curated Layer)
- **Dimension Tables:** `dim_customer`, `dim_product`, `dim_category`, `dim_shipper`.
- **Fact Tables:** `fact_orders`, `fact_order_details`, `fact_shipments`.

---

## SQL Analytics & Insights (Amazon Athena)
Advanced SQL capabilities (such as `LAG()` window functions and `DENSE_RANK()`) are utilized to extract key business insights including revenue by category, MoM growth trends, top spenders, and shipping delivery performance.

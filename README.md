# AWS E-Commerce Data Engineering Pipeline

## Project Overview
This project is built from scratch with a heavy focus on **AWS cloud services** to design a complete, production-ready data pipeline. It handles real-time data ingestion via custom API endpoints, processes distributed data using PySpark, stores information across structured cloud storage zones, and serves fast serverless analytics directly on AWS.

---

## Architecture 

<img width="2081" height="1732" alt="aws project final arc" src="https://github.com/user-attachments/assets/3b4d8c67-b590-45fe-a7c6-c3a6ab36ca56" />

---
### Detailed Flow:

1. **Cloud Ingestion & Real-Time Layer:**
   - **Python Data Generator & FastAPI** $\rightarrow$ Generates and serves simulated e-commerce events locally.
   - **ngrok** $\rightarrow$ Bridges local environments to the cloud securely via tunneling.
   - **AWS Lambda** $\rightarrow$ Captures incoming payloads serverlessly and writes them straight into the **Amazon S3 Raw Zone**.

2. **Cloud Storage & Medallion Architecture (Amazon S3):**
   - **Raw Zone** $\rightarrow$ Stores initial immutable ingested files.
   - **Processed/Curated Zone** $\rightarrow$ Holds clean, optimized Parquet datasets.

3. **Transformation Layer (PySpark):**
   - **PySpark ETL** $\rightarrow$ Processes and models relational data into a clean **Star Schema**.

4. **AWS Analytics Stack:**
   - **AWS Glue Crawler** $\rightarrow$ Automatically discovers schemas and populates the **AWS Glue Data Catalog**.
   - **Amazon Athena** $\rightarrow$ Executes fast, serverless SQL queries on top of the S3 curated data.

---

## Data Engineering Best Practices & Optimizations
The pipeline incorporates core engineering patterns to ensure efficiency and scalability:
- **State Management & Checkpointing:** Tracks stream states precisely to avoid duplicates.
- **Incremental Processing & Batching:** Processes micro-batches instead of full re-loads to save compute time.
- **Schema Evolution:** Handles structural changes smoothly without breaking down-stream layers.
- **Partitioning & Columnar Storage:** Saves curated data in **Parquet format** partitioned by keys like `Country` and `OrderDate` to heavily optimize Amazon Athena query costs and speeds.

---

## Star Schema & Data Modeling (Curated Layer)
The relational data was processed via PySpark and structured into a dimensional model optimized for analytical reporting:

- **Dimension Tables:**
  - `dim_customer`: Customer demographic details and locations.
  - `dim_product`: Product catalog attributes and pricing.
  - `dim_category` & `dim_department`: Product categorization and department hierarchies.
  - `dim_supplier`: Vendor and supplier data.
  - `dim_employee`: Employee/sales staff records.
  - `dim_shipper`: Logistics and shipping providers.
  - `dim_date`: Time intelligence attributes.
  - `dim_payment_method`: Payment types and gateway options.
  - `dim_order_status`: Order lifecycle status mappings.

- **Fact Tables & Aggregates:**
  - `fact_order`: Transactional order headers and statuses.
  - `fact_order_detail`: Line-item metrics, quantities, and unit prices.
  - `fact_payment`: Payment transaction records.
  - `fact_shipment`: Shipping timelines and delivery logistics.
  - `fact_customer_sales`: Pre-aggregated analytical metrics for customer sales performance.

---

## SQL Analytics & Insights (Amazon Athena)
Advanced SQL capabilities (such as `LAG()` window functions and `DENSE_RANK()`) are utilized to extract key business insights including revenue by category, MoM growth trends, top spenders, and shipping delivery performance.

---
## 📂 Repository Structure
```text
aws-serverless-ecom-pipeline/
│
├── api/
│   └── ordering_api.py         # FastAPI application for real-time event streaming
├── aws/
│   ├── lambda/
│   │   └── lambda_function.py  # AWS Lambda function for serverless ingestion
│   └── glue/
│       └── Ecommerce_transformation.ipynb # PySpark notebook for transformations & Star Schema
├── data_generator/
│   └── generate_data.py        # data generator script
├── docs/                       #  documentation 
├── README.md                   
└── sql_analytics           # sql queries to extract insights

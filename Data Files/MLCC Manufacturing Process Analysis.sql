/* =========================================================
   MLCC MANUFACTURING PROCESS ANALYSIS
========================================================= */

USE mlcc_manufacturing;


/* =========================================================
   1. FACT MANUFACTURING
========================================================= */

CREATE OR REPLACE VIEW Fact_Manufacturing AS

SELECT
    Lot_ID,
    Batch_ID,
    STR_TO_DATE(Production_Date, '%Y-%m-%d') AS Production_Date,
    Shift,
    Operator,
    Material_Lot,
    Process,
    Checkpoint,

    Cycle_Time_sec,
    Temperature_C,
    `Humidity_%`,

    CAST(Pressure_MPa AS DECIMAL(10,3)) AS Pressure_MPa,
    CAST(Thickness_um AS DECIMAL(10,3)) AS Thickness_um,
    CAST(Alignment_um AS DECIMAL(10,3)) AS Alignment_um,
    CAST(`Shrinkage_%` AS DECIMAL(10,3)) AS Shrinkage_Percent,

    Furnace_Zone,

    CAST(Peak_Temp_C AS DECIMAL(10,3)) AS Peak_Temp_C,
    CAST(Capacitance_pF AS DECIMAL(12,3)) AS Capacitance_pF,
    CAST(ESR_mOhm AS DECIMAL(12,3)) AS ESR_mOhm,
    CAST(IR_GOhm AS DECIMAL(12,3)) AS IR_GOhm,
    CAST(Leakage_uA AS DECIMAL(12,3)) AS Leakage_uA,

    Visual_Score,
    Dimension_L_mm,
    Dimension_W_mm,
    Dimension_T_mm,

    SPC_Status,
    Maintenance_Status,
    Defect_Category,
    Defect_Mode,
    Disposition,
    Result,
    
    CONCAT(
    Product_Size, '_',
    Capacitance_Rating_pF, '_',
    Voltage_Rating_V
) AS Product_Key,

	CONCAT(Line, '_', Machine) AS Machine_Key,

    Product_Size,
    Capacitance_Rating_pF,
    Voltage_Rating_V,
    Machine,
    Line

FROM mlcc_raw_data;


/* =========================================================
   2. DIM PRODUCT
========================================================= */

CREATE OR REPLACE VIEW Dim_Product AS

SELECT DISTINCT

    CONCAT(
        r.Product_Size, '_',
        r.Capacitance_Rating_pF, '_',
        r.Voltage_Rating_V
    ) AS Product_Key,

    r.Product_Size,
    r.Capacitance_Rating_pF,
    r.Voltage_Rating_V,

    CAST(REPLACE(s.`Tolerance %`, '%', '') AS DECIMAL(5,2))
        AS Tolerance_Percent,

    CAST(REPLACE(s.LSL, ' pF', '') AS DECIMAL(10,2))
        AS LSL_pF,

    CAST(REPLACE(s.USL, ' pF', '') AS DECIMAL(10,2))
        AS USL_pF

FROM mlcc_raw_data AS r

LEFT JOIN mlcc_specifications AS s
    ON r.Capacitance_Rating_pF =
       CAST(REPLACE(s.`Nominal Capacitance`, ' pF', '') AS DECIMAL(10,2));
       
/* =========================================================
   3. DIM PROCESS
========================================================= */

CREATE OR REPLACE VIEW Dim_Process AS

SELECT DISTINCT
    Process,
    `Process No` AS Process_No

FROM mlcc_process_order;

/* =========================================================
   4. DIM MACHINE
========================================================= */

CREATE OR REPLACE VIEW Dim_Machine AS

SELECT DISTINCT
    CONCAT(Line, '_', Machine) AS Machine_Key,
    Machine,
    Line

FROM mlcc_raw_data;

/* =========================================================
   5. DIM DATE
========================================================= */

CREATE OR REPLACE VIEW Dim_Date AS

SELECT DISTINCT
    STR_TO_DATE(Production_Date, '%Y-%m-%d') AS Date,
    YEAR(STR_TO_DATE(Production_Date, '%Y-%m-%d')) AS Year,
    MONTH(STR_TO_DATE(Production_Date, '%Y-%m-%d')) AS Month_No,
    MONTHNAME(STR_TO_DATE(Production_Date, '%Y-%m-%d')) AS Month,
    QUARTER(STR_TO_DATE(Production_Date, '%Y-%m-%d')) AS Quarter,
    WEEK(STR_TO_DATE(Production_Date, '%Y-%m-%d'), 3) AS Week

FROM mlcc_raw_data;
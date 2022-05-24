-- Standardize Date Format

ALTER TABLE nashville_housing
ADD SaleDateConverted DATE;

UPDATE nashville_housing
SET SaleDateConverted = str_to_date(SaleDate, '%Y-%m-%d');

-- Confirm new column is date format
SHOW COLUMNS FROM nashville_housing;

----------------------------------------------------------------------------------
-- Populate Property Address data

UPDATE nashville_housing
SET PropertyAddress=IF(PropertyAddress='',NULL,PropertyAddress);

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IF(ISNULL(a.PropertyAddress), b.PropertyAddress, 'N/A')
FROM nashville_housing AS a
JOIN nashville_housing AS b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL; 

UPDATE a
SET PropertyAddress = IF(ISNULL(a.PropertyAddress), b.PropertyAddress, 'N/A')
FROM nashville_housing
--JOIN practicedb1.nashville_housing AS b
--    ON a.ParcelID = b.ParcelID
--    AND a.UniqueID <> b.UniqueID
--WHERE a.PropertyAddress IS NULL; 
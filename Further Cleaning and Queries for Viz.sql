-- Used MySQL to import and clean data in a database. Functions utilized: joins, window functions, CTEs, substrings

-- Standardize Date Format

ALTER TABLE nashville_housing
ADD SaleDateConverted DATE;

UPDATE nashville_housing
SET SaleDateConverted = str_to_date(SaleDate, '%Y-%m-%d');

SHOW COLUMNS FROM nashville_housing;

----------------------------------------------------------------------------------
-- Populate missing Property Address data

UPDATE nashville_housing
SET PropertyAddress=IF(PropertyAddress='',NULL,PropertyAddress);

UPDATE nashville_housing AS a
JOIN nashville_housing AS b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = b.PropertyAddress
WHERE ISNULL(a.PropertyAddress);

----------------------------------------------------------------------------------
-- Breaking out address into individual columns

SELECT PropertyAddress
FROM nashville_housing;

-- Split address using substring method

ALTER TABLE nashville_housing
MODIFY COLUMN PropertySplitAddress VARCHAR(255);

UPDATE nashville_housing
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress,',', 1);

ALTER TABLE nashville_housing
MODIFY COLUMN PropertySplitCity VARCHAR(255);

UPDATE nashville_housing
SET PropertySplitCity = SUBSTRING_INDEX(PropertyAddress,',', -1);

ALTER TABLE nashville_housing
ADD ownersplitaddress VARCHAR(255),
ADD ownersplitcity VARCHAR(255),
ADD ownersplitstate VARCHAR(255);

UPDATE nashville_housing
SET ownersplitaddress = SUBSTRING_INDEX(OwnerAddress,',', 1),
    ownersplitcity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',', 2),',',-1),
    ownersplitstate = SUBSTRING_INDEX(OwnerAddress,',', -1);

SELECT OwnerAddress, ownersplitaddress, ownersplitcity, ownersplitstate
FROM nashville_housing;

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2;

UPDATE nashville_housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END;

-- Identify and delete duplicate rows
WITH RowNumCTE AS(
SELECT *,
    row_number() OVER (
    PARTITION by ParcelID,
                    PropertyAddress,
                    SalePrice,
                    SaleDate,
                    LegalReference
                    ORDER BY
                        UniqueID
                        ) AS row_num

FROM nashville_housing
)
DELETE FROM nashville_housing USING nashville_housing JOIN RowNumCTE ON nashville_housing.UniqueID = RowNumCTE.UniqueID
WHERE row_num > 1
;

-- Drop unnecessary columns
ALTER TABLE nashville_housing
DROP OwnerAddress,
DROP TaxDistrict,
DROP PropertyAddress;

ALTER TABLE nashville_housing
DROP COLUMN SaleDate;

SELECT * FROM nashville_housing;

-- Remove invalid address rows
DELETE FROM nashville_housing
WHERE ownersplitaddress LIKE '0 %';

-- Drop all rows missing addresses
UPDATE nashville_housing
SET ownersplitaddress = NULL
WHERE ownersplitaddress LIKE '';

DELETE FROM nashville_housing
WHERE ownersplitaddress IS NULL;

ALTER TABLE nashville_housing
DROP PropertySplitAddress, DROP PropertySplitCity;

ALTER TABLE nashville_housing
ADD SaleDateMonth INT;

UPDATE nashville_housing
SET SaleDateMonth = MONTH(SaleDateConverted);

-- Write query to split home sales by month sold
SELECT DISTINCT(a.unique_count), a.SaleDateMonth
FROM
	(SELECT n.SaleDateMonth, COUNT(n.UniqueID) OVER(PARTITION BY n.SaleDateMonth ORDER BY n.SaleDateMonth) AS unique_count
    FROM practicedb1.nashville_housing AS n) AS a
ORDER BY a.SaleDateMonth;

SELECT DISTINCT(a.month_avg), a.SaleDateMonth
FROM
	(SELECT n.SaleDateMonth, AVG(n.SalePrice) OVER(PARTITION BY n.SaleDateMonth ORDER BY n.SaleDateMonth) AS month_avg
		FROM practicedb1.nashville_housing AS n) AS a
ORDER BY a.SaleDateMonth;

WITH BedCountsByRoomNumber AS (SELECT DISTINCT(n.bed_counts) AS distinct_bed_counts,
    n.Bedrooms AS bedroom_number FROM
        (SELECT n.Bedrooms, COUNT(n.UniqueID) OVER(PARTITION BY n.Bedrooms ORDER BY n.Bedrooms) AS bed_counts
            FROM practicedb1.nashville_housing AS n) AS n
    ORDER BY bedroom_number)
SELECT cte.distinct_bed_counts, cte.bedroom_number, cte.distinct_bed_counts/25668 AS bed_count_percentage
FROM BedCountsByRoomNumber AS cte;

SELECT DISTINCT(n.YearBuilt), AVG(n.SalePrice) OVER(PARTITION BY n.YearBuilt) AS avg_sale_price
FROM practicedb1.nashville_housing AS n
WHERE n.YearBuilt <> 0
ORDER BY n.YearBuilt;

SELECT DISTINCT(n.LandUse), AVG(n.SalePrice) OVER(PARTITION BY n.LandUse)
FROM practicedb1.nashville_housing AS n;
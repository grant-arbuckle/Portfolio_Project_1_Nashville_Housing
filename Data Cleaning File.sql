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

ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;

ALTER TABLE nashville_housing
DROP COLUMN SaleDate;
/*

Cleaning Data in SQL Queries

*/

SELECT * 
FROM PortfolioProject.nashvillehousing;


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --


-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(SaleDate, DATE)
FROM PortfolioProject.nashvillehousing;

ALTER TABLE nashvillehousing
ADD SaleDateConverted DATE;

UPDATE nashvillehousing
SET SaleDateConverted =  CONVERT(SaleDate, DATE);


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --


-- Populate Property Address data

SELECT *
FROM PortfolioProject.nashvillehousing
ORDER BY ParcelID;


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.nashvillehousing a
JOIN PortfolioProject.nashvillehousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

/* 
--  no NULL PropertyAddress in the dataset

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress);
FROM PortfolioProject.nashvillehousing a
JOIN PortfolioProject.nashvillehousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID;
*/


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --


-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.nashvillehousing;

SELECT
SUBSTR(PropertyAddress, 1, POSITION(',' IN PropertyAddress)-1) AS Address
, SUBSTR(PropertyAddress, POSITION(',' IN PropertyAddress) + 1, LENGTH(PropertyAddress)) AS Address
FROM PortfolioProject.nashvillehousing;


ALTER TABLE nashvillehousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE nashvillehousing
SET PropertySplitAddress = SUBSTR(PropertyAddress, 1, POSITION(',' IN PropertyAddress)-1);


ALTER TABLE nashvillehousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE nashvillehousing
SET PropertySplitCity = SUBSTR(PropertyAddress, POSITION(',' IN PropertyAddress) + 1, LENGTH(PropertyAddress));


SELECT
OwnerAddress
, SUBSTRING_INDEX(OwnerAddress,',', 1) AS Address
, SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',', 2), ',', -1) AS City
, SUBSTRING_INDEX(OwnerAddress, ',', -1) AS State
FROM nashvillehousing; 


ALTER TABLE nashvillehousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress,',', 1);


ALTER TABLE nashvillehousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',', 2), ',', -1);


ALTER TABLE nashvillehousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);


SELECT *
FROM nashvillehousing; 


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldASVacant), COUNT(SoldAsVacant)
FROM nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END
FROM nashvillehousing;


UPDATE nashvillehousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END;


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --


-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *
, ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num
FROM nashvillehousing
ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

CREATE TABLE nashvillehousing_noDupe LIKE nashvillehousing;
INSERT INTO nashvillehousing_noDupe SELECT * FROM nashvillehousing;

delete t1
FROM nashvillehousing_noDupe t1 INNER JOIN
(
SELECT UniqueID
, ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num
FROM nashvillehousing) t2 ON t1.UniqueID = t2.UniqueID 
WHERE t2.row_num > 1;


-- check if has dupe
WITH RowNumCTE AS (
SELECT *
, ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num
FROM nashvillehousing_noDupe
ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --


-- Delete Unused Columns


SELECT *
FROM nashvillehousing;

ALTER TABLE nashvillehousing
-- DROP COLUMN OwnerAddress,
-- DROP COLUMN TaxDistrict,
-- DROP COLUMN PropertyAddress
DROP COLUMN SaleDate;


SELECT *
FROM nashvillehousing;




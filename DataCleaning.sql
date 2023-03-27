
USE [DC]
GO

-- Cleaning Data in SQL Queries

SELECT *
FROM DC.dbo.NashvilleHousing



-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(DATE, Saledate)
FROM DC.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET Saledateconverted = CONVERT(DATE, Saledate)



-- Populate Property Address Data

SELECT *
FROM DC.dbo.NashvilleHousing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT PID.ParcelID, PID.PropertyAddress, PA.ParcelID, PA.PropertyAddress, ISNULL(PID.PropertyAddress, PA.PropertyAddress)
FROM DC.dbo.NashvilleHousing AS PID
JOIN DC.dbo.NashvilleHousing AS PA
	ON PID.ParcelID = PA.ParcelID
	AND PID.UniqueID <> PA.UniqueID
WHERE PID.PropertyAddress IS NULL


UPDATE PID
SET PropertyAddress = ISNULL(PID.PropertyAddress, PA.PropertyAddress)
FROM DC.dbo.NashvilleHousing AS PID
JOIN DC.dbo.NashvilleHousing AS PA
	ON PID.ParcelID = PA.ParcelID
	AND PID.UniqueID <> PA.UniqueID
WHERE PID.PropertyAddress IS NULL



-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM DC.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
	--CHARINDEX(',', PropertyAddress)
FROM DC.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))



-- Cleaning Owner Adress using PARSENAME
SELECT OwnerAddress
FROM DC.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM DC.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM DC.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM DC.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END
FFROM DC.dbo.NashvilleHousing



-- Removal of Duplicate

WITH RowNumbCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_numb

FROM DC.dbo.NashvilleHousing
)
-- Select *
DELETE
FROM RowNumbCTE
WHERE row_numb > 1
-- ORDER BY PropertyAddress


-- Delete Unused Column

SELECT *
FROM DC.dbo.NashvilleHousing

ALTER TABLE DC.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate
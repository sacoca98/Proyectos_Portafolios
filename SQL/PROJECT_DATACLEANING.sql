/* 

Cleaning Data in SQL Queries

*/

SELECT *
FROM NashvilleHouse

-----------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM NashvilleHouse

Update NashvilleHouse
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHouse
ADD SaleDateConverted Date;

Update NashvilleHouse
SET SaleDateConverted = CONVERT(Date, SaleDate)


-----------------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address Data (Filling Null Values)

SELECT *
FROM NashvilleHouse
WHERE PropertyAddress is null


SELECT *
FROM NashvilleHouse
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHouse A
JOIN NashvilleHouse B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null

Update A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHouse A
JOIN NashvilleHouse B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null

-----------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address Into Individual Columns (Address, City, State)


-- Substrings

SELECT PropertyAddress
FROM NashvilleHouse

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as 
FROM NashvilleHouse

ALTER TABLE NashvilleHouse
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHouse
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHouse
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHouse
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


SELECT OwnerAddress
FROM Portafolio_Projects.dbo.NashvilleHouse

-- PARSENAME

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Portafolio_Projects.dbo.NashvilleHouse

ALTER TABLE NashvilleHouse
ADD OwnerSplitAddress Nvarchar(255);

Update NashvilleHouse
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHouse
ADD OwnerSplitCity Nvarchar(255);

Update NashvilleHouse
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHouse
ADD OwnerSplitState Nvarchar(255);

Update NashvilleHouse
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-----------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portafolio_Projects.DBO.NashvilleHouse
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, 
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM Portafolio_Projects.DBO.NashvilleHouse

Update NashvilleHouse
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


-----------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) row_num
FROM NashvilleHouse
)

DELETE
FROM RowNumCTE
WHERE row_num > 1


-----------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM Portafolio_Projects.dbo.NashvilleHouse

ALTER TABLE Portafolio_Projects.dbo.NashvilleHouse
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Portafolio_Projects.dbo.NashvilleHouse
DROP COLUMN SaleDate
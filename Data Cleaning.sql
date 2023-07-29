--Cleaning Data in SQL Queries

SELECT *
FROM DataCleaningPortofolio.dbo.NashvilleHousing

--Standarize Date Format

SELECT SaleDate, SaleDateConvertedDate, CONVERT(date, SaleDate) as SaleDateConverted
FROM DataCleaningPortofolio.dbo.NashvilleHousing

ALTER TABLE DataCleaningPortofolio.dbo.NashvilleHousing
Add SaleDateConvertedDate Date;

UPDATE DataCleaningPortofolio.dbo.NashvilleHousing
SET SaleDateConvertedDate = CONVERT(Date, SaleDate)


--Populate Property Address Data

SELECT *
FROM DataCleaningPortofolio.dbo.NashvilleHousing
--WHERE PropertyAddress is Null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaningPortofolio.dbo.NashvilleHousing a
JOIN DataCleaningPortofolio.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is Null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaningPortofolio.dbo.NashvilleHousing a
JOIN DataCleaningPortofolio.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is Null


--Breaking out Address into Individual Column (Address, City, State)

SELECT PropertyAddress
FROM DataCleaningPortofolio.dbo.NashvilleHousing
--WHERE PropertyAddress is Null
--ORDER BY ParcelID

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address, 
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM DataCleaningPortofolio.dbo.NashvilleHousing

ALTER TABLE DataCleaningPortofolio.dbo.NashvilleHousing
Add PropertySplitAddress nvarchar(255);

UPDATE DataCleaningPortofolio.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE DataCleaningPortofolio.dbo.NashvilleHousing
Add PropertySplitCity nvarchar(255);

UPDATE DataCleaningPortofolio.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM DataCleaningPortofolio..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM DataCleaningPortofolio..NashvilleHousing

ALTER TABLE DataCleaningPortofolio.dbo.NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

UPDATE DataCleaningPortofolio.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE DataCleaningPortofolio.dbo.NashvilleHousing
Add OwnerSplitCity nvarchar(255);

UPDATE DataCleaningPortofolio.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE DataCleaningPortofolio.dbo.NashvilleHousing
Add OwnerSplitState nvarchar(255);

UPDATE DataCleaningPortofolio.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM DataCleaningPortofolio..NashvilleHousing




--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM DataCleaningPortofolio..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM DataCleaningPortofolio..NashvilleHousing

UPDATE DataCleaningPortofolio..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

--Remove Duplicates 

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM DataCleaningPortofolio..NashvilleHousing
--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1

SELECT *
FROM DataCleaningPortofolio..NashvilleHousing

--Delete Unused Columns

SELECT *
FROM DataCleaningPortofolio..NashvilleHousing

ALTER TABLE DataCleaningPortofolio..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate, SaleDateConvertedDate
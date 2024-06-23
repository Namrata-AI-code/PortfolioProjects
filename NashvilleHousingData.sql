/*
Cleaning data with SQL Queries
*/
SELECT *
FROM NashvilleHousingData..NashvilleHousing$

--Standardize Date Format
SELECT SaleDate, CONVERT(date,SaleDate)
FROM NashvilleHousingData..NashvilleHousing$

UPDATE NashvilleHousing$
SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE NashvilleHousing$
ADD SaleDateConverted date

UPDATE NashvilleHousing$
SET SaleDateConverted = CONVERT(date,SaleDate)

SELECT SaleDateConverted
FROM NashvilleHousingData..NashvilleHousing$

--Populate Property address data
SELECT *
FROM NashvilleHousingData..NashvilleHousing$
ORDER BY ParcelID

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousingData..NashvilleHousing$ a
JOIN NashvilleHousingData..NashvilleHousing$ b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is null 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousingData..NashvilleHousing$ a
JOIN NashvilleHousingData..NashvilleHousing$ b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is null 

--Breaking out address into individual columns i.e (address,city,state)
SELECT PropertyAddress
FROM NashvilleHousingData..NashvilleHousing$

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
FROM NashvilleHousingData..NashvilleHousing$

ALTER TABLE NashvilleHousingData..NashvilleHousing$
ADD PropertySplitAddress Nvarchar(255)

UPDATE NashvilleHousingData..NashvilleHousing$
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousingData..NashvilleHousing$
ADD PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousingData..NashvilleHousing$
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

--Splitting owner address
SELECT OwnerAddress
FROM NashvilleHousingData..NashvilleHousing$

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3) as address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) as city,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as state
FROM NashvilleHousingData..NashvilleHousing$

ALTER TABLE NashvilleHousingData..NashvilleHousing$
ADD OwnerSplitAddress Nvarchar(255)

UPDATE NashvilleHousingData..NashvilleHousing$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousingData..NashvilleHousing$
ADD OwnerSplitCity Nvarchar(255)

UPDATE NashvilleHousingData..NashvilleHousing$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousingData..NashvilleHousing$
ADD OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousingData..NashvilleHousing$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Change Y and N to Yes and No in SoldAsVacant field
SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM NashvilleHousingData..NashvilleHousing$
GROUP BY SoldAsVacant

SELECT SoldAsVacant 
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No' 
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousingData..NashvilleHousing$

UPDATE NashvilleHousingData..NashvilleHousing$
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No' 
	 ELSE SoldAsVacant
	 END

--Remove Duplicates
WITH RowNumCTE AS
(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference ORDER BY UniqueID) as row_num
FROM NashvilleHousingData..NashvilleHousing$
)
DELETE
FROM RowNumCTE
WHERE row_num>1

--Delete unused columns
ALTER TABLE  NashvilleHousingData..NashvilleHousing$
DROP COLUMN PropertyAddress,SaleDate,TaxDistrict,OwnerAddress


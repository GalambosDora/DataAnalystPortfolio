/*

Cleaning Data in SQL queries

*/

SELECT *
FROM CleaningPortfolioProject.dbo.NashvilleHousing

-- Change Date Format, removing hourly marks
-- Creating a new column and selecting it

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM CleaningPortfolioProject.dbo.NashvilleHousing

UPDATE CleaningPortfolioProject.dbo.NashvilleHousing
	SET SaleDate = CONVERT (Date, Saledate)

ALTER TABLE CleaningPortfolioProject.dbo.NashvilleHousing
	ADD SaleDateConverted Date;

UPDATE CleaningPortfolioProject.dbo.NashvilleHousing
	SET SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate property address data
-- Using the matching ParcelID to populate the PropertyAddress column that has 'NULL' values

SELECT *
FROM CleaningPortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM CleaningPortfolioProject.dbo.NashvilleHousing as a
JOIN CleaningPortfolioProject.dbo.NashvilleHousing as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
		-- Using a self join the find records that share the same parcel ID (but not the same Unique ID)
		-- Using 'ISNULL' to populate based on the available b.PropertyAddress data
WHERE a.PropertyAddress is null 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM CleaningPortfolioProject.dbo.NashvilleHousing as a
JOIN CleaningPortfolioProject.dbo.NashvilleHousing as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Breaking out Address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address
		-- Finding out the position of the comma and substracting 1 so that the comma itself is not part of the address
	, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
		-- Separating the city name, it start 1 character after the comma and ends according to the length of the city name
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
	ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
	SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)
	-- Adding and populating a split column for the address

ALTER TABLE NashvilleHousing
	ADD PropertySplitCity NVARCHAR (255);

UPDATE NashvilleHousing
	SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))
	-- Adding and populating a split column for the city

SELECT PropertySplitAddress, PropertySplitCity
FROM NashvilleHousing

-- Splitting the address of the owner (Address, City, State) using 'PARSENAME'

SELECT OwnerAddress
FROM NashvilleHousing

SELECT 
	PARSENAME(REPLACE(Owneraddress, ',', '.'), 3),
	PARSENAME(REPLACE(Owneraddress, ',', '.'), 2),
	PARSENAME(REPLACE(Owneraddress, ',', '.'), 1)
	-- Parsename separates at dots so we have to replace commas
	-- Parsename goes backwards this is why we use 3-2-1
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
	ADD OwnerSplitAddress NVARCHAR (255);

UPDATE NashvilleHousing
	SET OwnerSplitAddress =PARSENAME(REPLACE(Owneraddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
	ADD OwnerSplitCity NVARCHAR (255);

UPDATE NashvilleHousing
	SET OwnerSplitCity =PARSENAME(REPLACE(Owneraddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
	ADD OwnerSplitState NVARCHAR (255);

UPDATE NashvilleHousing
	SET OwnerSplitState =PARSENAME(REPLACE(Owneraddress, ',', '.'), 1)
	-- Adding and updating 3 columns to separate the data


-- Change Y and N to Yes and No in 'Sold as Vacant' Field

SELECT DISTINCT(SoldASVacant), COUNT(SoldASVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2
	-- Finding out how many values we have under 'SoldAsVacant' and counting them


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant ='N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM NashvilleHousing

UPDATE NashvilleHousing
	SET SoldAsVacant = 
		CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant ='N' THEN 'No'
			ELSE SoldAsVacant
			END

-- Removing Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY PropertyAddress)
	row_num
FROM NashvilleHousing
)
	-- Using CTE to find duplicate rows

DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

-- Delete columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate
	--Deleting the original data that we have altered previously



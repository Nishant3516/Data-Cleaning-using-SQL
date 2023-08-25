-- Retrieve all columns from the NashVilleHousing table
SELECT * FROM NashVilleHousing;

-- Convert the SaleDate column to the date data type
UPDATE NashVilleHousing
SET SaleDate = CONVERT(date, SaleDate);

-- Select rows where PropertyAddress is NULL
SELECT *
FROM NashVilleHousing
WHERE PropertyAddress IS NULL;

-- Select and combine specific columns from two instances of NashVilleHousing using a JOIN
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashVilleHousing a
JOIN NashVilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID];

-- Update PropertyAddress using the combined PropertyAddress values from the previous query
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashVilleHousing a
JOIN NashVilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID];

-- Select PropertyAddress values from NashVilleHousing
SELECT PropertyAddress FROM NashVilleHousing;

-- Extract the street and city components from PropertyAddress
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
       SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 
FROM NashVilleHousing;

-- Add PropertyAddressStreet column and update its values
ALTER TABLE NashVilleHousing
ADD PropertyAddressStreet nvarchar(255);

UPDATE NashVilleHousing SET PropertyAddressStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

-- Add PropertyAddressCity column and update its values
ALTER TABLE NashVilleHousing
ADD PropertyAddressCity nvarchar(255);

UPDATE NashVilleHousing SET PropertyAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

-- Parse and split OwnerAddress into separate columns for address components
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as AddressState,
       PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as AddressCity,
       PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as Address
FROM NashVilleHousing;

-- Add OwnerAddressA column and update its values
ALTER TABLE NashVilleHousing
ADD OwnerAddressA nvarchar(255);

UPDATE NashVilleHousing SET OwnerAddressA = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

-- Add OwnerAddressCity column and update its values
ALTER TABLE NashVilleHousing
ADD OwnerAddressCity nvarchar(255);

UPDATE NashVilleHousing SET OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

-- Add OwnerAddressState column and update its values
ALTER TABLE NashVilleHousing
ADD OwnerAddressState nvarchar(255);

UPDATE NashVilleHousing SET OwnerAddressState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

-- Count and group SoldAsVacant values
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashVilleHousing
GROUP BY SoldAsVacant;

-- Update SoldAsVacant values to 'Yes' or 'No'
UPDATE NashVilleHousing
SET SoldAsVacant = CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END;

-- Use a common table expression (CTE) with row numbering to identify and delete duplicate rows
WITH RowNumCTE AS (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
        ORDER BY UniqueId
    ) row_num
    FROM NashVilleHousing
)
DELETE FROM RowNumCTE
WHERE row_num > 1;

-- Drop the unwanted columns (OwnerAddress, PropertyAddress, and TaxDistrict) from the table
ALTER TABLE NashVilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict;

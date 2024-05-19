Select propertyaddress from nashvillehousing
	where uniqueid::int = ANY('{43076,39432,45290,53147,43080,45295,48731}'::int[])

	

--- Populate Property Address Data


SELECT a.uniqueid, a.propertyaddress, coalesce(a.propertyaddress,b.propertyaddress)
FROM nashvillehousing as a
JOIN nashvillehousing as b
on a.ParcelID = b.ParcelID
AND a.uniqueID != b.uniqueID 
WHERE a.propertyaddress IS NULL

UPDATE nashvillehousing
SET propertyaddress = COALESCE(a.propertyaddress, b.propertyaddress)
FROM nashvillehousing AS a
JOIN nashvillehousing AS b
ON a.ParcelID = b.ParcelID AND a.uniqueID != b.uniqueID
WHERE nashvillehousing.propertyaddress IS NULL;
	

-- Breaking out address into individual colum (address, city, state)

Select * FROM nashvillehousing

-- Strpos is CHARINDEX in MySQL
SELECT 
SUBSTRING(Propertyaddress, 1, strpos(PropertyAddress,',') - 1) As Address,
	TRIM(SUBSTRING(Propertyaddress, strpos(PropertyAddress,',') + 1, LENGTH(PropertyAddress))) As City
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress VARCHAR(128);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(Propertyaddress, 1, strpos(PropertyAddress,',') - 1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity VARCHAR(128);

UPDATE NashvilleHousing
SET PropertySplitCity = TRIM(SUBSTRING(Propertyaddress, strpos(PropertyAddress,',') + 1, LENGTH(PropertyAddress)));


-- Breaking out column from OwnerProperty using PARSENAME
Select OwnerAddress from Nashvillehousing

-- SPLIT_PART() is PostgreSQL's PARSENAME
SELECT SPLIT_PART(OwnerAddress, ',', 1),TRIM(SPLIT_PART(OwnerAddress, ',', 2)),TRIM(SPLIT_PART(OwnerAddress, ',', 3)) 
	FROM NashvilleHousing ;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress VARCHAR(128);

UPDATE NashvilleHousing
SET OwnerSplitAddress = SPLIT_PART(OwnerAddress, ',', 1);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity VARCHAR(128);

UPDATE NashvilleHousing
SET OwnerSplitCity = TRIM(SPLIT_PART(OwnerAddress, ',', 2));

ALTER TABLE NashvilleHousing
ADD OwnerSplitState VARCHAR(128);

UPDATE NashvilleHousing
SET OwnerSplitState = TRIM(SPLIT_PART(OwnerAddress, ',', 3)) ;

Select * FROM NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant Field"
	
SELECT DISTINCT(soldasvacant), count(soldasvacant)
FROM NashvilleHousing
GROUP BY Soldasvacant
	
SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET soldasvacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END


-- Remove Duplicates
	
/* RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID
	) As Row_Num
FROM NashvilleHousing
	)
SELECT * 
	FROM RowNumCTE
WHERE Row_Num >1;*/ -- Unable to delete using this (You cannot delete record from CTE table in PostGreSQL)

--Able to run using this )
DELETE FROM NashvilleHousing
WHERE (ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, UniqueID) IN (
    SELECT ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, UniqueID
    FROM (
        SELECT *,
            ROW_NUMBER() OVER(
                PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID
            ) AS Row_Num
        FROM NashvilleHousing
    ) AS RowNumCTE
    WHERE Row_Num > 1
);
	
SELECT * FROM NashvilleHousing


-- Delete Unused Columns

SELECT * FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, 
	DROP COLUMN PropertyAddress,
DROP COLUMN TaxDistrict

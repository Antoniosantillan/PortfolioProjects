----Cleaning Data in SQL Queries
SELECT *
FROM Nashville_Housing_Data

----Standarsize Date Format
SELECT SaleDate,
	   strftime(SaleDate)
FROM Nashville_Housing_Data

UPDATE Nashville_Housing_Data
SET SaleDate=strftime(SaleDate)

ALTER TABLE Nashville_Housing_Data
ADD SaleDateConverted date

UPDATE Nashville_Housing_Data
SET SaleDateConverted=strftime(SaleDate)

----Populate Property Address Data
SELECT a.ParcelID,
	   a.UniqueID,
	   a.PropertyAddress,
	   b.ParcelID,
	   b.UniqueID,
	   b.PropertyAddress,
	   coalesce(a.PropertyAddress,b.PropertyAddress) AS New_Address
FROM Nashville_Housing_Data as a
JOIN Nashville_Housing_Data as b
	ON a.ParcelID=b.ParcelID
	AND a.UniqueID<>b.UniqueID
WHERE a.PropertyAddress IS NULL


CREATE TEMPORARY TABLE Temp_NonNullValues AS
SELECT DISTINCT ParcelID, PropertyAddress
FROM Nashville_Housing_Data
WHERE PropertyAddress IS NOT NULL;


UPDATE Nashville_Housing_Data
SET PropertyAddress = (
    SELECT PropertyAddress
    FROM Temp_NonNullValues
    WHERE Temp_NonNullValues.ParcelID = Nashville_Housing_Data.ParcelID
)
WHERE PropertyAddress IS NULL;

DROP TABLE IF EXISTS Temp_NonNullValues;

--Breaking Out Address into Individual Columns (Address,City,State)

SELECT substr(PropertyAddress,1,instr("PropertyAddress",",")-1) AS PropertySplitAddress,
	   substr(PropertyAddress,instr("PropertyAddress",",")+1,length(PropertyAddress)) AS PropertySplitCity
FROM Nashville_Housing_Data

ALTER TABLE Nashville_Housing_Data
ADD PropertySplitAddress

UPDATE Nashville_Housing_Data
SET PropertySplitAddress=substr(PropertyAddress,1,instr("PropertyAddress",",")-1)

ALTER TABLE Nashville_Housing_Data
ADD PropertySplitCity

UPDATE Nashville_Housing_Data
SET PropertySplitCity=substr(PropertyAddress,instr("PropertyAddress",",")+1,length(PropertyAddress))

-- Change Y and N to YES and NO in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant),
	   count(SoldAsVacant)
FROM Nashville_Housing_Data
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
	   CASE SoldAsVacant 
			WHEN "Y" THEN "YES"
			WHEN "N" THEN "NO"
			END
FROM Nashville_Housing_Data

UPDATE Nashville_Housing_Data
SET SoldAsVacant=CASE SoldAsVacant 
			WHEN "Y" THEN "Yes"
			WHEN "N" THEN "No"
			ELSE SoldAsVacant
			END
			
--Remove Duplicates
--see duplicate values:

SELECT *,
	   row_number() OVER (PARTITION BY  ParcelID,
										PropertyAddress,
										SaleDate,
										LegalReference ORDER BY UniqueID) as row_num
FROM Nashville_Housing_Data
ORDER BY ParcelID
--Delete duplicate:
DELETE FROM Nashville_Housing_Data
WHERE UniqueID IN (
    SELECT UniqueID
    FROM (
        SELECT UniqueID,
               ROW_NUMBER() OVER (
                   PARTITION BY ParcelID,
                                PropertyAddress,
                                SaleDate,
                                LegalReference
                   ORDER BY UniqueID
               ) AS row_num
        FROM Nashville_Housing_Data
    ) AS RowNumCTE
    WHERE row_num > 1
);

--Delete Unused Columns

SELECT *
FROM Nashville_Housing_Data

ALTER TABLE Nashville_Housing_Data
DROP COLUMN TaxDistrict
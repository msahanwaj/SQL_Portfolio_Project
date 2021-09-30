

/*
Cleaning Data in SQL Queries
*/


Select * 
from
Housing_data.dbo.Housing_table

-------------------------------------------------------------------------------------------------------------------------------------------------------
--Date Formating
Select saleDateConverted, CONVERT(Date,SaleDate) 
from Housing_data.dbo.Housing_table

Update Housing_table
SET SaleDate =  CONVERT(Date,SaleDate)

ALTER TABLE Housing_table
ADD SaleDateConverted Date;

Update Housing_table
SET SaleDateConverted =  CONVERT(Date,SaleDate)


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Populated Property Address data
Select *
from
Housing_data.dbo.Housing_table
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL (a.PropertyAddress,b.PropertyAddress)
from Housing_data.dbo.Housing_table a
JOIN Housing_data.dbo.Housing_table b
on a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress =  ISNULL (a.PropertyAddress,b.PropertyAddress)
from Housing_data.dbo.Housing_table a
JOIN Housing_data.dbo.Housing_table b
on a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-----------------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Colimns(Address,City,State)

Select PropertyAddress
from Housing_data.dbo.Housing_table
--where PropertyAddress is null
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX (',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress)+1,LEN(PropertyAddress)) as Address
from Housing_data.dbo.Housing_table 

ALTER TABLE Housing_table
ADD PropertySplitAddress Nvarchar(255);

Update Housing_table
SET PropertySplitAddress =  SUBSTRING(PropertyAddress, 1, CHARINDEX (',', PropertyAddress)-1)

ALTER TABLE Housing_table
ADD PropertySplitCity Nvarchar(255);

Update Housing_table
SET PropertySplitAddress =  SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress)+1, LEN(PropertyAddress))


Select * 
from
Housing_data.dbo.Housing_table

Select OwnerAddress 
from
Housing_data.dbo.Housing_table


Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
from Housing_data.dbo.Housing_table

ALTER TABLE Housing_table
Add OwnerSplitAddress Nvarchar(255);

Update Housing_table
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)



ALTER TABLE Housing_table
Add OwnerSplitCity Nvarchar(255);

Update Housing_table
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE Housing_table
Add OwnerSplitState Nvarchar(255);

Update Housing_table
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From Housing_data.dbo.Housing_table

----------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Housing_data.dbo.Housing_table
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Housing_data.dbo.Housing_table

Update Housing_table
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
--------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Housing_data.dbo.Housing_table
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From Housing_data.dbo.Housing_table

--------------------------------------------------------------------------------------

Select *
From Housing_data.dbo.Housing_table


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



-- Check if the data is loaded 
select * 
from [NashvilleHousing csv]

-----------------------------------
-- Populate Property Address data
select *
from [NashvilleHousing csv]
--where PropertyAddress is null 
order by ParcelID 

-- Shows a same Parcel ID but with Property Address and No Property Address then fixing
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(b.PropertyAddress, a.PropertyAddress)
from [NashvilleHousing csv] a
join [NashvilleHousing csv] b 
on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
where b.PropertyAddress is null 

update b
set PropertyAddress = ISNULL(b.PropertyAddress, a.PropertyAddress)
from [NashvilleHousing csv] a
join [NashvilleHousing csv] b 
on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
where b.PropertyAddress is null  

-- Breaking out Property Address into Individual Comlumn (City) using Substring

select PropertyAddress
from [NashvilleHousing csv]

select 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , len(PropertyAddress)) as City
from [NashvilleHousing csv] 


alter table[NashvilleHousing csv]
add PropertySplitCity NVARCHAR(255)

update [NashvilleHousing csv]
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , len(PropertyAddress))

select *
from [NashvilleHousing csv]


-- Another way to break out Owner Address into 3 individual columns by using Parsename
select OwnerAddress
from [NashvilleHousing csv]

select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City, 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as States
from [NashvilleHousing csv]

alter table [NashvilleHousing csv]
add OwnerSplitAddress VARCHAR(255) 

update [NashvilleHousing csv]
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 

alter table [NashvilleHousing csv]
add OwnerSplitCity VARCHAR(255)

update [NashvilleHousing csv]
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 

alter table [NashvilleHousing csv]
add OwnerSplitStates VARCHAR(255)

update [NashvilleHousing csv]
set OwnerSplitStates = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 

select * 
from [NashvilleHousing csv]

-- Change Y and N to Yes and No in "Sold as Vacant" column
select distinct(SoldAsVacant)
from [NashvilleHousing csv]


select SoldAsVacant, 
        case when SoldAsVacant = 'Y' then 'Yes' 
                when SoldAsVacant = 'N' then 'No'
        else SoldAsVacant
        END 
from [NashvilleHousing csv]

update [NashvilleHousing csv]
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes' 
                when SoldAsVacant = 'N' then 'No'
                 else SoldAsVacant
                END

-- Show Duplicates

with RowNumCTE AS (
select *, 
    ROW_NUMBER() OVER ( 
        PARTITION BY ParcelID, 
                    PropertyAddress, 
                    SalePrice, 
                    SaleDate,
                    LegalReference
        order by UniqueID
    ) as row_num
from [NashvilleHousing csv] 
)

select * 
from RowNumCTE
where row_num > 1
order by PropertyAddress

-- Remove Duplicates 

with RowNumCTE AS (
select *, 
    ROW_NUMBER() OVER ( 
        PARTITION BY ParcelID, 
                    PropertyAddress, 
                    SalePrice, 
                    SaleDate,
                    LegalReference
        order by UniqueID
    ) as row_num
from [NashvilleHousing csv] 
)

DELETE
from RowNumCTE 
where row_num > 1 

-- Delete Unused Columns 

alter table [NashvilleHousing csv]
drop column PropertyAddress, OwnerAddress, TaxDistrict 
-- we can choose any columns that we do not need to fill in above query

select * 
from [NashvilleHousing csv] 


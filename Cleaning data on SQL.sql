

--cleaning data in sql queries


select*
from PortfolioProject..[Nashville housing]


-- standardize data format

select saledateconverted, CONVERT(date,saledate)
from PortfolioProject..[Nashville housing]


update [Nashville housing]
set SaleDate = CONVERT(date,saledate) 


alter table [nashville housing]
add saledateconverted date

update [Nashville housing]
set saledateconverted = CONVERT(date,saledate)

--populate property address data

select*
from PortfolioProject..[Nashville housing]
--where PropertyAddress is null
order by ParcelID

select a.parcelid, a.PropertyAddress, b.parcelid, b.PropertyAddress, ISNULL(a.propertyaddress,b.PropertyAddress)
from PortfolioProject..[Nashville housing] a
join PortfolioProject..[Nashville housing] b
on a.parcelid = b.parcelid
and a.[UniqueID ] <> b.[UniqueID ]
where a.propertyaddress is null 

update a
set PropertyAddress = ISNULL(a.propertyaddress,b.PropertyAddress)
from PortfolioProject..[Nashville housing] a
join PortfolioProject..[Nashville housing] b
on a.parcelid = b.parcelid
and a.[UniqueID ] <> b.[UniqueID ]
where a.propertyaddress is null 


--breaking out address into individual colums (address, city, state)

select PropertyAddress
from PortfolioProject..[Nashville housing]
--where PropertyAddress is null
--order by ParcelID

select 
SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress) -1) as address
, SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as address

from PortfolioProject..[Nashville housing]

alter table [nashville housing]
add propertysplitaddress nvarchar(255);

update [Nashville housing]
set propertysplitaddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table [nashville housing]
add propertysplitcity nvarchar(255);

update [Nashville housing]
set propertysplitcity = SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress) +1, LEN(Propertyaddress))



select*
from PortfolioProject..[Nashville housing]



select OwnerAddress 
from PortfolioProject..[Nashville housing]


select 
PARSENAME(replace(owneraddress,',','.') , 3)
,PARSENAME(replace(owneraddress,',','.') , 2)
,PARSENAME(replace(owneraddress,',','.') , 1)
from PortfolioProject..[Nashville housing]


alter table [nashville housing]
add ownersplitaddress nvarchar(255);

update [Nashville housing]
set ownersplitaddress = PARSENAME(replace(owneraddress,',','.') , 3)

alter table [nashville housing]
add ownersplitcity nvarchar(255);

update [Nashville housing]
set ownersplitcity = PARSENAME(replace(owneraddress,',','.') , 2)

alter table [nashville housing]
add ownersplitstate nvarchar(255);

update [Nashville housing]
set ownersplitstate = PARSENAME(replace(owneraddress,',','.') , 1)


select *
from PortfolioProject..[Nashville housing]

-- change Y and N into Yes and NO in "sold as vacant" field

select distinct(soldasvacant), count(soldasvacant)
from PortfolioProject..[Nashville housing]
group by SoldAsVacant
order by 2


select SoldAsVacant
,case when soldasvacant = 'Y' then 'yes'
when SoldAsVacant = 'N' then 'No'
else soldasvacant
end
from PortfolioProject..[Nashville housing]


update [Nashville housing]
set SoldAsVacant = case when soldasvacant = 'Y' then 'yes'
when SoldAsVacant = 'N' then 'No'
else soldasvacant
end


--remove duplicates 

with rownumCTE as(
select*,
row_number() over (
partition by parcelid, 
             propertyaddress,
             saleprice,
             saledate,
             legalreference 
			 order by
			 uniqueid
			 ) row_num 

from PortfolioProject..[Nashville housing]
--order by ParcelID
)
select*
from rownumCTE
where row_num > 1
order by PropertyAddress

select*
from PortfolioProject..[Nashville housing]


--Delete unused columns

select *
from PortfolioProject..[Nashville housing]


alter table PortfolioProject..[Nashville housing]
drop column owneraddress, taxdistrict, propertyaddress

alter table PortfolioProject..[Nashville housing]
drop column saledate
sector_hashes = Sector::load_sectors
#puts "the sector hashes are:"
#puts sector_hashes.to_s
$sectors = sector_hashes[:sector_counter_to_name]
$sectors_name_to_counter = sector_hashes[:sector_name_to_counter]
Result.reload_front_page_trend

## a list of positive and negative indicators 
## 
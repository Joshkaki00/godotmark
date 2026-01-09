#!/usr/bin/env python3
"""
Download nature benchmark assets from Poly Haven
This will download the glTF files with their binary data
"""

import os
import requests
import json
from pathlib import Path

# List of assets based on what was in the project
ASSETS = [
    "pine_tree_01",
    "fir_tree_01", 
    "pine_sapling_medium",
    "jacaranda_tree",
    "tree_small_02",
    "island_tree_01",
    "island_tree_02",
    "island_tree_03",
    "fir_sapling",
    "fir_sapling_medium",
    "pine_sapling_small",
    "quiver_tree_01",
    "quiver_tree_02",
    "searsia_burchellii",
    "searsia_lucida",
    "coast_rocks_02",
    "coast_rocks_03",
    "coast_land_rocks_04",
    "coast_line_02",
    "sand_rocks_small_01",
    "root_cluster_01",
    "root_cluster_02",
    "boulder_01",
    "namaqualand_boulder_02",
    "namaqualand_boulder_03",
    "namaqualand_cliff_02",
    "rock_face_01",
    "rock_face_02",
    "rock_face_03",
    "rock_moss_set_01",
    "rock_moss_set_02",
    "stone_01",
    "moon_rock_01",
    "dead_tree_trunk",
    "dead_tree_trunk_02",
    "dead_quiver_trunk",
    "tree_stump_01",
    "tree_stump_02",
    "pine_roots",
    "single_root",
    "bark_debris_01",
    "dry_branches_medium_01",
    "shrub_01",
    "shrub_02",
    "shrub_03",
    "shrub_04",
    "wild_rooibos_bush",
    "anthurium_botany_01",
    "calathea_orbifolia_01",
    "pachira_aquatica_01",
    "fern_02",
    "nettle_plant",
    "periwinkle_plant",
    "weed_plant_02",
    "celandine_01",
    "dandelion_01",
    "flower_empodium",
    "flower_gazania",
    "flower_heliophila",
    "flower_stinkkruid",
    "flower_ursinia",
    "cheiridopsis_succulent",
    "crystalline_iceplant",
    "othonna_cerarioides",
    "grass_bermuda_01",
    "grass_medium_01",
    "grass_medium_02",
    "moss_01",
    "forest_floor",
    "forest_ground_04",
    "forest_leaves_02",
    "forest_leaves_03",
    "forrest_ground_01",
    "forrest_ground_03",
    "leaves_forest_ground",
    "park_dirt",
    "rocky_trail",
    "brown_mud",
    "brown_mud_02",
    "brown_mud_03",
    "brown_mud_dry",
    "red_dirt_mud_01",
    "burned_ground_01",
    "coast_sand_01",
    "coast_sand_02",
    "coast_sand_rocks_02",
    "mountainside",
]

OUTPUT_DIR = Path("art/nature-benchmark")
RESOLUTION = "2k"  # Download 2K versions

def download_asset(asset_name):
    """Download a single asset from Poly Haven"""
    print(f"Downloading {asset_name}...")
    
    # Poly Haven API endpoint
    api_url = f"https://api.polyhaven.com/files/{asset_name}"
    
    try:
        response = requests.get(api_url)
        if response.status_code != 200:
            print(f"  [WARN] Asset not found: {asset_name}")
            return False
        
        data = response.json()
        
        # Get the glTF download URL for 2K resolution
        if "gltf" in data and RESOLUTION in data["gltf"]:
            gltf_data = data["gltf"][RESOLUTION]
            
            # Download the main glTF file
            if "gltf" in gltf_data:
                gltf_url = gltf_data["gltf"]["url"]
                gltf_response = requests.get(gltf_url)
                if gltf_response.status_code == 200:
                    output_path = OUTPUT_DIR / f"{asset_name}_{RESOLUTION}.gltf"
                    output_path.write_bytes(gltf_response.content)
                    print(f"  [OK] Downloaded: {asset_name}_{RESOLUTION}.gltf")
            
            # Download the .bin file from the include section
            if "gltf" in gltf_data and "include" in gltf_data["gltf"]:
                includes = gltf_data["gltf"]["include"]
                for filename, file_info in includes.items():
                    if filename.endswith(".bin"):
                        bin_url = file_info["url"]
                        bin_size = file_info["size"]
                        print(f"  Downloading {filename} ({bin_size / (1024*1024):.1f} MB)...")
                        bin_response = requests.get(bin_url)
                        if bin_response.status_code == 200:
                            bin_output_path = OUTPUT_DIR / filename
                            bin_output_path.write_bytes(bin_response.content)
                            print(f"  [OK] Downloaded: {filename}")
                            return True
            
            # If no separate bin, the glTF might be embedded
            return True
        else:
            print(f"  [WARN] No {RESOLUTION} glTF available for {asset_name}")
            return False
            
    except Exception as e:
        print(f"  [ERROR] Error downloading {asset_name}: {e}")
        return False

def main():
    print("=" * 60)
    print("Poly Haven Asset Downloader for GodotMark")
    print("=" * 60)
    print(f"\nDownloading {len(ASSETS)} assets to {OUTPUT_DIR}")
    print(f"Resolution: {RESOLUTION}")
    print("\nThis may take a while...\n")
    
    # Create output directory
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    success_count = 0
    fail_count = 0
    
    for i, asset in enumerate(ASSETS, 1):
        print(f"[{i}/{len(ASSETS)}] ", end="")
        if download_asset(asset):
            success_count += 1
        else:
            fail_count += 1
    
    print("\n" + "=" * 60)
    print(f"Download complete!")
    print(f"  [OK] Success: {success_count}")
    print(f"  [FAIL] Failed: {fail_count}")
    print("=" * 60)
    
    if fail_count > 0:
        print("\nNote: Some assets may have different names on Poly Haven.")
        print("You may need to search manually for failed downloads.")

if __name__ == "__main__":
    main()


import yaml
import os
import sys

def gen_metadata(output_path, asset_name, frame_count=1, pivot_x=8, pivot_y=8):
    data = {
        "asset_name": asset_name,
        "type": "sprite_8dir",
        "frame_count": frame_count,
        "frame_duration_ms": 100 if frame_count > 1 else 0,
        "pivot": {
            "x": pivot_x,
            "y": pivot_y
        },
        "collision_box": {
            "width": pivot_x * 2,
            "height": pivot_y * 2
        },
        "directions": ["N", "NE", "E", "SE", "S", "SW", "W", "NW"],
        "flags": ["lit"]
    }
    
    with open(output_path, 'w') as f:
        yaml.dump(data, f, default_flow_style=False)
    print(f"Metadata generated at {output_path}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python gen_metadata.py <output_file> <asset_name>")
    else:
        gen_metadata(sys.argv[1], sys.argv[2])

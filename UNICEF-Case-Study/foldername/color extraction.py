
#UNICEF Image Color Extraction
#Uses Google Vision API to extract dominant colors and calculate luminance from social media images


import pandas as pd
from google.cloud import vision
import os
import io
from pathlib import Path


IMAGE_DIR = "data/downloaded_media"
INPUT_CSV = "data/social_media_postings_with_photos.csv"
OUTPUT_CSV = "data/social_media_with_colors.csv"

# Set Google Cloud credentials and download your credentials JSON from Google Cloud Console
# CREDENTIALS_PATH = "here your credentials.json"
# os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = CREDENTIALS_PATH

# functions
#we get dominant color and we  take rgb values and calculated luminance

def get_dominant_color(image_path):
   
    try:
        # Initialize Vision API client
        client = vision.ImageAnnotatorClient()
        
        with io.open(image_path, 'rb') as image_file:
            content = image_file.read()
        
        # Create image object
        image = vision.Image(content=content)
        
        # Request image properties
        response = client.image_properties(image=image)
        props = response.image_properties_annotation
        
        # we take the mst dominant color in the picture
        dominant_color = props.dominant_colors.colors[0].color
        
        # here we extract RGB values
        r = dominant_color.red
        g = dominant_color.green
        b = dominant_color.blue
        
        # Calculate luminance 
        # Luminance = 0.299*R + 0.587*G + 0.114*B - this is a standrad method from harvard
        luminance = 0.299 * r + 0.587 * g + 0.114 * b
        
        return {
            'R': r,
            'G': g,
            'B': b,
            'Luminance': luminance
        }
        
    except Exception as e:
        print(f"✗ Error processing {image_path}: {e}")
        return {
            'R': None,
            'G': None,
            'B': None,
            'Luminance': None
        }

# we have to classify color into warm cool or neutral category 
def classify_color(r, g, b):
  
    if r is None or g is None or b is None:
        return None
        
    if r > g and r > b:
        return "Warm"
    elif b > r and b > g:
        return "Cool"
    elif g > r and g > b:
        return "Cool"
    else:
        return "Neutral"

# process 
def main():
    """Main function to process all images and extract color data"""
    
    print("\n" + "="*60)
    print("UNICEF Image Color Extraction")
    print("="*60 + "\n")
    
    # Check if credentials are set
    if 'GOOGLE_APPLICATION_CREDENTIALS' not in os.environ:
        print("⚠️  WARNING: Google Cloud credentials not found!")
        print("Please set GOOGLE_APPLICATION_CREDENTIALS environment variable")
        print("Example: export GOOGLE_APPLICATION_CREDENTIALS='path/to/credentials.json'")
        return
    
    # Load data
    print(f"📂 Loading data from: {INPUT_CSV}")
    try:
        data = pd.read_csv(INPUT_CSV)
        print(f"✓ Loaded {len(data)} posts\n")
    except FileNotFoundError:
        print(f"✗ Error: File not found: {INPUT_CSV}")
        return
    
    # Process each image
    print("🎨 Extracting colors from images...\n")
    color_data = []
    
    for idx, row in data.iterrows():
        # Progress indicator
        if (idx + 1) % 50 == 0:
            print(f"   Processed {idx + 1}/{len(data)} images...")
        
        # Check if photo file exists
        if pd.isna(row.get('photo_file')) or row.get('photo_file') == 'NA':
            color_data.append({
                'R': None, 
                'G': None, 
                'B': None, 
                'Luminance': None,
                'Color_Category': None
            })
            continue
        
        # Build image path
        image_path = os.path.join(IMAGE_DIR, row['photo_file'])
        
        # Check if file exists
        if not os.path.exists(image_path):
            print(f"✗ File not found: {image_path}")
            color_data.append({
                'R': None, 
                'G': None, 
                'B': None, 
                'Luminance': None,
                'Color_Category': None
            })
            continue
        
        # Extract color
        colors = get_dominant_color(image_path)
        
        # Classify color
        colors['Color_Category'] = classify_color(
            colors['R'], 
            colors['G'], 
            colors['B']
        )
        
        color_data.append(colors)
        
        if (idx + 1) % 10 == 0:
            print(f"✓ Processed: {row['photo_file']}")
    
    # Create DataFrame from color data
    color_df = pd.DataFrame(color_data)
    
    # Add color data to original dataset
    data = pd.concat([data, color_df], axis=1)
    
    # Save results
    print(f"\n💾 Saving results to: {OUTPUT_CSV}")
    data.to_csv(OUTPUT_CSV, index=False)
    
    # Summary statistics
    print("\n" + "="*60)
    print("SUMMARY")
    print("="*60)
    print(f"Total posts processed: {len(data)}")
    print(f"Images with color data: {color_df['R'].notna().sum()}")
    print(f"Missing color data: {color_df['R'].isna().sum()}")
    
    if color_df['Color_Category'].notna().any():
        print("\nColor Category Distribution:")
        print(color_df['Color_Category'].value_counts())
        
        print("\nLuminance Statistics:")
        print(color_df['Luminance'].describe())
    
    print(f"\n✓ Color extraction complete!")
    print(f"✓ Output saved to: {OUTPUT_CSV}\n")

if __name__ == "__main__":
    main()
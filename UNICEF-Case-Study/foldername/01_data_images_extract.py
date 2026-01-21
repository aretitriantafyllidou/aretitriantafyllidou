import pandas as pd
import requests
from bs4 import BeautifulSoup
import os

# Load dataset from CSV
file_path = "/Users/aretitriantafyllidou/Desktop/Masters/block 3/data files/social_media_postings.csv"  # Replace with your file path
data = pd.read_csv(file_path)




# Ensure the target directory for saving media exists
new_directory = "downloaded_media_2"
os.makedirs(new_directory, exist_ok=True)  # Create "downloaded_media_2" folder if it doesn't exist

def download_image_or_video(url, platform, index):
    headers = {'User-Agent': 'Mozilla/5.0'}
    try:
        # Request the URL
        response = requests.get(url, headers=headers)
        soup = BeautifulSoup(response.text, 'html.parser')

        # Determine media URL based on platform
        if platform.lower() == "facebook" or platform.lower() == "instagram":
            media_url = soup.find('meta', property="og:image")['content']
        elif platform.lower() == "tiktok":
            media_url = soup.find('meta', property="og:image")['content']
        elif platform.lower() == "x":  # Twitter (formerly X)
            media_url = soup.find('meta', property="og:image")['content']
        else:
            print(f"Unsupported platform: {platform}")
            return None  # Return None if platform is unsupported

        # Fetch and save the media
        media_data = requests.get(media_url).content
        file_name = f"{index}.jpg"  # Save file with index as the name
        file_path = os.path.join(new_directory, file_name)  # Save in the new directory
        with open(file_path, 'wb') as file:
            file.write(media_data)
        print(f"Saved {platform} media for row {index}: {file_name}")
        return file_name  # Return the file name if successful
    except Exception as e:
        print(f"Failed to download media from {url} on {platform}: {e}")
        return None  # Return None if the download fails


# Iterate over rows and process each link
for index, row in data.iterrows():
    platform = row['network']
    link = row['link']
    photo_file = download_image_or_video(link, platform, index + 1)  # Use index + 1 for 1-based naming
    if photo_file:
        data.at[index, "photo_file"] = photo_file  # Update dataset with photo file name
    else:
        data.at[index, "photo_file"] = "NA"  # Mark as NA if download failed

# Save the updated dataset to a new CSV file
output_file_path = "/Users/aretitriantafyllidou/Desktop/Masters/block 3/data files/social_media_postings_with_photos.csv"
data.to_csv(output_file_path, index=False)
print(f"Updated dataset saved to {output_file_path}")

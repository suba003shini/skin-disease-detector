import os
import shutil
import random

# Set paths
original_dataset_dir = "all_images"  # Change if needed
train_dir = "skin_images_dataset/train"
val_dir = "skin_images_dataset/val"

# Set split ratio
split_ratio = 0.8  # 80% train, 20% val

# Create train and val directories
for root_dir in [train_dir, val_dir]:
    os.makedirs(root_dir, exist_ok=True)

# Process each class folder
for class_name in os.listdir(original_dataset_dir):
    class_path = os.path.join(original_dataset_dir, class_name)
    if os.path.isdir(class_path):
        images = os.listdir(class_path)
        random.shuffle(images)

        split_point = int(len(images) * split_ratio)
        train_images = images[:split_point]
        val_images = images[split_point:]

        # Make subdirectories in train/val folders
        train_class_dir = os.path.join(train_dir, class_name)
        val_class_dir = os.path.join(val_dir, class_name)
        os.makedirs(train_class_dir, exist_ok=True)
        os.makedirs(val_class_dir, exist_ok=True)

        # Copy files
        for img in train_images:
            shutil.copy(os.path.join(class_path, img), os.path.join(train_class_dir, img))

        for img in val_images:
            shutil.copy(os.path.join(class_path, img), os.path.join(val_class_dir, img))

print("✅ Dataset split completed: train and val folders are ready.")

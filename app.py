from flask import Flask, request, jsonify
from flask_cors import CORS
import tensorflow as tf
import numpy as np
from PIL import Image
import io

app = Flask(__name__)
CORS(app)  # Enable Cross-Origin Requests from your Android app

# Load model once when server starts
model = tf.keras.models.load_model('skin_model.h5')

# Class names
class_names = ['moluscum', 'allergy', 'scar', 'pimple', 'vitiligo', 'wart']

# Advice for each disease
advice = {
    'moluscum': 'Consult a doctor. Avoid sharing personal items.',
    'allergy': 'Avoid allergens. Use prescribed creams.',
    'scar': 'Use scar-reducing creams. Doctor visit not necessary.',
    'pimple': 'It will cure in 3–4 days. Keep the area clean.',
    'vitiligo': 'Consult a dermatologist. Home remedies not recommended.',
    'wart': 'Avoid scratching. Visit a doctor for removal options.'
}

@app.route('/')
def home():
    return "Skin Disease Detector Backend is Running!"

@app.route('/predict', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({'error': 'No image uploaded'}), 400

    try:
        image_file = request.files['image']
        image = Image.open(image_file).resize((128, 128))
        image = np.array(image) / 255.0
        image = np.expand_dims(image, axis=0)

        predictions = model.predict(image)
        class_index = np.argmax(predictions[0])
        predicted_class = class_names[class_index]
        prediction_advice = advice[predicted_class]

        return jsonify({
            'prediction': predicted_class,
            'advice': prediction_advice
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ✅ This line is important to allow access from your Android device
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

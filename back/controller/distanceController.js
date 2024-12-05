const axios = require('axios');

// Function to calculate distance using Haversine formula
function calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; // Radius of the Earth in kilometers
    const dLat = (lat2 - lat1) * (Math.PI / 180);
    const dLon = (lon2 - lon1) * (Math.PI / 180);

    const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(lat1 * (Math.PI / 180)) * Math.cos(lat2 * (Math.PI / 180)) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);

    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c; // Distance in kilometers
}

// Function to get coordinates from OpenCage
async function getCoordinates(locationName) {
    const apiKey = '0c995573f7b8417caa8d7941ac26ca24'; // Replace with your OpenCage API key
    const url = `https://api.opencagedata.com/geocode/v1/json?q=${encodeURIComponent(locationName)}&key=${apiKey}`;

    const response = await axios.get(url);
    if (response.data.results.length > 0) {
        const { lat, lng } = response.data.results[0].geometry;
        return { lat, lng };
    } else {
        throw new Error('Location not found');
    }
}

exports.getDistance = async (req, res) => {
    const { location1, location2 } = req.body;

    if (!location1 || !location2) {
        return res.status(400).json({ error: 'Please provide both location1 and location2.' });
    }

    try {
        const coords1 = await getCoordinates(location1);
        const coords2 = await getCoordinates(location2);

        const distance = calculateDistance(coords1.lat, coords1.lng, coords2.lat, coords2.lng);
        res.status(200).json({ distance: distance.toFixed(2) }); // Return distance in kilometers
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

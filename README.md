All of the codes I used in the data display have comments on what they do. Next steps include:
1. Convert the ToT energy into keV with the data rescources provided by the CTU.
2. Filter out 'noisy' pixels - one pixel events that appear for more than one frame in the same place. Create mask of them and just throw them out. Number of detected noisy pixels may raise with the altitude, it's good to get the data when they appeared.
3. Make the existing plots slightly more readable - co the peak is clearly visible (moving averege etc.)
4. Write the classification of the tracks (as in the articles: straight track, curly track etc. ...) normally or using neural networks. It's good to experiment with the input atributes.

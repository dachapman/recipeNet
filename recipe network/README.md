#  Neural Network Recipe Predictor

This neural network was written in Swift as a follow up to the "A Competitive Neural Network Model of the Cockroach Escape Response" thesis.

Input to the network will be a binary list of ingredients, output will be a recommended ingredient to add to the recipe.
Training data:  take recipes, remove one ingredient, and then predict what was removed.  We will remember what was removed and then compare the predicted ingredient to the one we removed.

Training data was processed and cleaned from https://www.kaggle.com/hugodarwood/epirecipes. To expand the training data, one ingredient was removed at a time.

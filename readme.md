# Additional considerations

## Staging through regions
- Depends on the intended target design. For example: 
  - Should the pipeline always deploy to x regions for each parameter file? - Then it would make sense to add the region to the matrix
  - Should the pipeline deploy to a specific region and optional to others? - In that case one could implement a similar logic as currently implemented for the parameter files per environment
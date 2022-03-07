tool_exec <- function(in_params, out_params)
{
  input.fc <- in_params[[1]]
  magic.number <- in_params[[2]]
  out.fc <- out_params[[1]]
  
  data <- arc.select(arc.open(input.fc))
  data["NEW_FIELD"] <- magic.number
  arc.write(out.fc, data)
}

alias MyHeadsUp.Repo
alias MyHeadsUp.Incident
alias MyHeadsUp.Incidents.Incident
import Ecto.Query

# Video 23 Exercises

# Macros
# all pending incidents, ordering by descending priority
Incident
|> where(status: :pending)
|> order_by(desc: :priority)
|> Repo.all()
|> IO.inspect()

# incidents with a priority >= 2, ordered by ascending name
Incident
|> where([i], i.priority >= 2)
|> order_by(:name)
|> Repo.all()
|> IO.inspect()

# incidents that have "meow " anywhere in the description
Incident
|> where([i], ilike(i.description, "%meow%"))
|> Repo.all()
|> IO.inspect()

# first incident
Incident |> first(:id) |> Repo.one()

# last incident
Incident |> last(:id) |> Repo.one()

# Query Language

# all resolved incidents, ordering by descending priority
query = from Incident, where: [status: :resolved], order_by: [desc: :priority]
query
|> Repo.all()
|> IO.inspect()

# incidents that hve "wandering" in the description
query = from i in Incident, where: ilike(i.description, "%wandering%")
query
|> Repo.all()
|> IO.inspect()

# incidents with a priority < 2, ordered by ascending name
query = from i in Incident, where: i.priority < 2
query
|> Repo.all()
|> IO.inspect()



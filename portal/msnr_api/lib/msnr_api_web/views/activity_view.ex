defmodule MsnrApiWeb.ActivityView do
  use MsnrApiWeb, :view
  alias MsnrApiWeb.ActivityView

  def render("index.json", %{activities: activities}) do
    %{data: render_many(activities, ActivityView, "activity.json")}
  end

  def render("show.json", %{activity: %{type: _type}} = activity) do
    %{data: render_one(activity, ActivityView, "activity.json")}
  end

  def render("show.json", %{activity: activity} ) do
    %{data: render_one(activity, ActivityView, "activity_short.json")}
  end

  def render("activity_short.json", %{activity: activity}) do
    %{id: activity.id,
      starts_sec: activity.starts_sec,
      ends_sec: activity.ends_sec}
  end

  def render("activity.json", %{activity: activity}) do
    %{id: activity.id,
      starts_sec: activity.starts_sec,
      ends_sec: activity.ends_sec,
      type: activity.type,
      is_group: activity.is_group,
      name: activity.name,
      description: activity.description,
      points: activity.points}
  end
end

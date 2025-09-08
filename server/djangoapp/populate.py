from .models import CarMake, CarModel

def initiate():
    # If already seeded, do nothing
    if CarModel.objects.exists():
        return

    # --- Car makes ---
    car_make_data = [
        {"name": "NISSAN",   "description": "Great cars. Japanese technology"},
        {"name": "Mercedes", "description": "Great cars. German technology"},
        {"name": "Audi",     "description": "Great cars. German technology"},
        {"name": "Kia",      "description": "Great cars. Korean technology"},
        {"name": "Toyota",   "description": "Great cars. Japanese technology"},
    ]

    makes_by_name = {}
    for d in car_make_data:
        make, _ = CarMake.objects.get_or_create(
            name=d["name"],
            defaults={"description": d["description"]}
        )
        makes_by_name[d["name"]] = make

    # --- Car models ---
    car_model_data = [
        {"name": "Pathfinder", "type": "SUV",   "year": 2023, "make": "NISSAN"},
        {"name": "Qashqai",    "type": "SUV",   "year": 2023, "make": "NISSAN"},
        {"name": "XTRAIL",     "type": "SUV",   "year": 2023, "make": "NISSAN"},

        {"name": "A-Class",    "type": "SUV",   "year": 2023, "make": "Mercedes"},
        {"name": "C-Class",    "type": "SUV",   "year": 2023, "make": "Mercedes"},
        {"name": "E-Class",    "type": "SUV",   "year": 2023, "make": "Mercedes"},

        {"name": "A4",         "type": "SUV",   "year": 2023, "make": "Audi"},
        {"name": "A5",         "type": "SUV",   "year": 2023, "make": "Audi"},
        {"name": "A6",         "type": "SUV",   "year": 2023, "make": "Audi"},

        {"name": "Sorento",    "type": "SUV",   "year": 2023, "make": "Kia"},
        {"name": "Carnival",   "type": "SUV",   "year": 2023, "make": "Kia"},
        {"name": "Cerato",     "type": "SEDAN", "year": 2023, "make": "Kia"},

        {"name": "Corolla",    "type": "SEDAN", "year": 2023, "make": "Toyota"},
        {"name": "Camry",      "type": "SEDAN", "year": 2023, "make": "Toyota"},
        {"name": "Kluger",     "type": "SUV",   "year": 2023, "make": "Toyota"},
    ]

    for d in car_model_data:
        CarModel.objects.get_or_create(
            name=d["name"],
            car_make=makes_by_name[d["make"]],
            defaults={"type": d["type"], "year": d["year"]}
        )

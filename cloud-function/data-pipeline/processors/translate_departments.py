#!/usr/bin/env python3

from datapackage_pipelines.wrapper import ingest, spew

# Department translation mapping
DEPARTMENT_TRANSLATIONS = {
    "საერთო დანიშნულების მომსახურება": "General Public Services",
    "ეკონომიკური საქმიანობა": "Economic Affairs", 
    "სოციალური დაცვა": "Social Protection",
    "ჯანმრთელობის დაცვა": "Health",
    "განათლება": "Education",
    "საბინაო-კომუნალური მეურნეობა": "Banking and Agriculture",
    "დასვენება, კულტურა რელიგია": "Culture, Religion, Recreation and Sport",
    "საზოგადოებრივი წესრიგი და უშიშროება": "Public Order and Safety",
    "გარემოს დაცვა": "Environment Protection",
    "თავდაცვა": "Defense"  # Note: might be a typo in original, keeping as is
}


def process_resource(rows):
    """Process rows and translate department names"""
    
    for row in rows:
        # Get the Georgian department name
        georgian_name = row.get('name', '')
        
        # Find translation (clean up whitespace for better matching)
        georgian_clean = ' '.join(georgian_name.split())
        english_name = DEPARTMENT_TRANSLATIONS.get(georgian_clean, georgian_name)
        
        # Update the row with English name
        row['name'] = english_name
        
        yield row


def modify_datapackage(datapackage):
    """Modify the datapackage to include the new field"""
    
    # Add new field for Georgian name
    for resource in datapackage['resources']:
        # Update the English name field description
        for field in resource['schema']['fields']:
            if field['name'] == 'name':
                field['title'] = 'Department Name (English)'
                field['description'] = 'Translated department name'
    
    return datapackage


if __name__ == '__main__':
    parameters, datapackage, resources = ingest()
    
    # Modify datapackage to add translation field
    datapackage = modify_datapackage(datapackage)
    
    # Process each resource
    def process_resources(resources):
        for rows in resources:
            yield process_resource(rows)
    
    spew(datapackage, process_resources(resources)) 
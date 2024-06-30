public with sharing class Utilities {
    public static String escapeSingleQuotes(String input) {
        return input != null ? input.replaceAll('\'', '\\\'') : '';  // Escapes single quotes by doubling them
    }
    

        public static List<SObject> getFieldSetData(String sObjectType, String fieldSetName, String whereClause) {
            
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(sObjectType);
            if (objType == null) {
                throw new IllegalArgumentException('Invalid SObject Type: ' + sObjectType);
            }
            
            // Get the FieldSet for the given SObject
            Schema.FieldSet fieldSet = objType.getDescribe().fieldSets.getMap().get(fieldSetName);
            if (fieldSet == null) {
                throw new IllegalArgumentException('Invalid FieldSet Name: ' + fieldSetName);
            }
            
            // Build the SOQL Query String using fields from the FieldSet
            List<String> fieldNames = new List<String>();
            for (Schema.FieldSetMember f : fieldSet.getFields()) {
                fieldNames.add(f.getFieldPath());
            }
            
            String query = 'SELECT ' + String.join(fieldNames, ', ') + ' FROM ' + sObjectType;
            
            if (whereClause != null && whereClause != '') {
                query += ' WHERE ' + whereClause;
            }
            query = escapeSingleQuotes(query);
            // Execute the Query and Return Results

            
            return Security.stripInaccessible(AccessType.READABLE, Database.query(query)).getRecords();
        }
   
    
}
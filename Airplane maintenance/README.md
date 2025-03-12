### **Airline Maintenance Schedules**  
The rule project models an automated maintenance scheduling system for aircraft. It ensures timely servicing based on aircraft usage (miles, hours, or days in service) to maintain safety and performance. Each rulesheet represents a specific maintenance action triggered by conditions such as total miles traveled, engine hours, or the passage of time.

---

### **Types of Decisions Being Made**  
1. **Aircraft Usage Calculation**  
   - Determines aircraft age and total usage in miles and hours.  
   - Establishes the basis for maintenance intervals.  

2. **Routine Maintenance Scheduling**  
   - Assigns periodic checks (e.g., oil changes every 3,000 miles, tire replacements every 5,000 miles).  

3. **Conditional Maintenance Actions**  
   - Uses modulus operations to determine when maintenance is due.  
   - Accounts for proximity to maintenance thresholds (e.g., if an aircraft is within 250 miles of a scheduled tire change, replace tires anyway).  

4. **Annual and Hour-Based Maintenance**  
   - Triggers maintenance based on days in service (e.g., engine coolant change every 365 days).  
   - Ensures critical components (e.g., transmission fluid, drive train lubrication) are serviced based on flight hours.  

---

### **Corticon Concepts Demonstrated**  
1. **Collection Operators**  
   - `plane.maintenance += Maintenance.new[description='Change Headlamp', estimatedCost=15.00]`  
   - Adds new maintenance actions dynamically to an aircraft’s maintenance list.  

2. **Mathematical Operators**  
   - `plane.totalHours.mod ( 1000)`  
   - `plane.ageInDays * 200`  
   - Uses modulus to check when maintenance is due.  

3. **Filters**  
   - `plane.totalMiles>0 ENABLED`  
   - Prevents rules from executing on new aircraft with no recorded mileage.  

4. **Time-Based Logic**  
   - `plane.purchaseDate.daysBetween(plane.serviceDate)`  
   - Calculates aircraft age to schedule maintenance events based on time.  

This ruleflow provides a structured and automated approach to aircraft maintenance scheduling, ensuring compliance with best practices for aviation upkeep.
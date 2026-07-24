# Information Architecture

The SmartStall Operator app uses a flat, hub-and-spoke navigation model built on GoRouter. The **Dashboard** acts as the central command hub, routing users to specific, isolated functional modules.

## Screen Hierarchy

1. **Splash Screen** (/splash)
   - Initial loading state. Redirects to Dashboard automatically.
2. **Dashboard** (/)
   - The central grid of modules.
   - **Hub** for all main navigation.
3. **Modules (Spokes)**
   - **Automatic Cleaning** (/auto-cleaning)
   - **Manual Control** (/manual-control)
   - **Training Studio** (/training)
   - **ArUco Scanner** (/aruco-scanner)
   - **Connection Manager** (/connection)
   - **Maintenance** (/maintenance)
   - **History** (/history)
   - **Settings** (/settings)

## Navigation Hierarchy
Users navigate from the Dashboard into a specific module, complete their task, and return to the Dashboard using the standard NavigationHeader back button. Deep linking is natively supported by GoRouter using the constants defined in AppRoutes.

## Future Expansion Points
- **Nested Routing in Settings**: Settings can be expanded to include /settings/profile, /settings/robot-preferences, etc.
- **Nested Routing in History**: History can include specific detailed log views (e.g. /history/:id).
- **Authentication**: If added later, an Auth Guard can be applied at the GoRouter root level to redirect unauthenticated users to /login.

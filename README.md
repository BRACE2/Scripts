# BRACE2 Scripts

- `ssid` System Identification
- `sees` Visualization
- `sdof` SDOF integration
- `xsection`
- `quakeio` Parsing
- `CE58658` Bridge model pre-processing
- `HMP`
- `HMP:apps/events`              Motion API
- `HMP:apps/inventory/scripts`   Scraping bridge data
- `./preprocessing`
- `./postprocessing`
- `opensees.sections` Section rendering / processing

<!--
## To-Do
- **Demonstration**
  - **Requirements**
      - [ ] *Response history plot*
      - [ ] Period elongation
      - [ ] *Metric active selection*
      - [ ] Clean metric cards
      - [ ] Remove `index.html`
      - [ ] Style modal report
      - [ ] **Deployment**

  - **Refinement**
    - [ ] Delete HTML comments
    - [ ] Response history (should we make plot on rendering side?)
    - [ ] Predictor refinements (work on numerical results)
      - [ ] Switch to XML, minimize intermediate file generation
    - [ ] Other bridges
    - [ ] Refine Hayward model results
    - [ ] Consolidate Hayward for deployment


- **January**

-->


<details>
<summary>
<a href="render_sam">render_sam</a> : Structure renderer.
</summary>
  Contributors: Arpit Nema, Chrystal Chern, @claudioperez
</details>

<details>
<summary>
<a href="system_identification">system_identification</a> MATLAB system identification tools.
</summary>
  Contributors: Prof. Mosalam, @claudioperez
</details>

<details>
<summary>
[csmip-tables](csmip-tables)
</summary>
  Contributors: @claudioperez
</details>

<details>
<summary>
<a href="brace2-plots">brace2-plots</a> 
</summary>
  <a href="https://stackoverflow.com/questions/35851201/how-can-i-share-matplotlib-style">source</a>
  Contributors: @claudioperez, Arpit Nema
</details>

### Scripts

- `quakeio <motion.zip>`
- `postprocessing/compareRH {method} <sensorRH> <modelRH>`
- `renderModel <modelDef> [nodalResponse]`
- `postprocessing/getSensorResponse <event.zip>`
- `preprocessing/makePattern <event.zip>`


<details><summary><code>fiberStrains <sectionResponse> -> {ele: coords/strains}</code> section response to strains
</summary>

</details>


- `getSBDS <sectionResponse>` strains to damage state
- `getDrift <groundMotion>`
- `getPDCA_Damage <drift> <pushover>`
- `renderState`

### File Types


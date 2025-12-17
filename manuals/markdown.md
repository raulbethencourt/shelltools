# Markdown Tutorial

## What is Markdown?

Markdown is a lightweight markup language that you can use to format plain text documents.  Write
docs for your GitHub projects, edit your GitHub profile _README_ etc. You fill find it all here.  

Let's dive into it. ⤵️

<!--toc:start-->
- [Markdown Tutorial](#markdown-tutorial)
  - [What is Markdown?](#what-is-markdown)
    - [Table of Contents](#table-of-contents)
  - [Paragraph](#paragraph)
  - [Headings](#headings)
- [Heading 1](#heading-1)
  - [Heading 2](#heading-2)
    - [Heading 3](#heading-3)
      - [Heading 4](#heading-4)
        - [Heading 5](#heading-5)
          - [Heading 6](#heading-6)
  - [Emphasis](#emphasis)
  - [Blockquote](#blockquote)
  - [Images](#images)
  - [Links](#links)
  - [Code](#code)
  - [Lists](#lists)
    - [Ordered List](#ordered-list)
    - [Unordered List](#unordered-list)
    - [Mixed List](#mixed-list)
  - [Table](#table)
  - [Task List](#task-list)
  - [Footnote](#footnote)
    - [I am working on a new project. [^1]](#i-am-working-on-a-new-project-1)
      - [Hope you will like it. [^see]](#hope-you-will-like-it-see)
  - [Jump to section](#jump-to-section)
  - [Horizontal Line](#horizontal-line)
  - [HTML](#html)
        - [Section with some ID](#section-with-some-id)
  - [Hello, welcome to my tutorial for markdown. 👋](#hello-welcome-to-my-tutorial-for-markdown-👋)
  - [What is markdown ?](#what-is-markdown)
  - [Why use markdown?](#why-use-markdown)
  - [Tools for markdown](#tools-for-markdown)
  - [Markdown Syntax](#markdown-syntax)
  - [Useful notes](#useful-notes)
<!--toc:end-->

## Paragraph

By writing regular text you are basically writing a paragraph.

```
This is a paragraph.
```

This is a paragraph.

---

## Headings

There are 6 heading variants. The number of "#" symbols, followed by text, indicates the importance of the heading.

```
# Heading 1
## Heading 2
### Heading 3
#### Heading 4
##### Heading 5
###### Heading 6
```

# Heading 1

## Heading 2

### Heading 3

#### Heading 4

##### Heading 5

###### Heading 6

---

## Emphasis

Modifying text is so neat and easy. You can make your text bold, italic and strikethrough.

```
Using two asterisks **this text is bold**.  
Two underscores __work as well__.  
Let's make it *italic now*.  
You guessed it, _one underscore is also enough_.  
Can we combine **_both of that_?** Absolutely.
What if I want to ~~strikethrough~~?
```

Using two asterisks **this text is bold**.  
Two underscores **work as well**.  
Let's make it _italic now_.  
You guessed it, _one underscore is also enough_.  
Can we combine **_both of that_?** Absolutely.  
What if I want to ~~strikethrough~~?

---

## Blockquote

Want to emphasise importance of the text? Say no more.

```
> This is a blockquote.
> Want to write on a new line with space between?
>
> > And nested? No problem at all.
> >
> > > PS. you can **style** your text _as you want_.
```

> This is a blockquote.
> Want to write on a new line with space between?
>
> > And nested? No problem at all.
> >
> > > PS. you can **style** your text _as you want_. :

---

## Images

The best way is to simply drag & drop image from your computer directly. You can also create reference to image and assign it that way.  
Here is the syntax.

```
![text if the image fails to load](auto-generated-path-to-file-when-you-upload-image "Text displayed on hover")

[logo]: auto-generated-path-to-file-when-you-upload-image "Hover me"
![error text][logo]
```

![text if the image fails to load](https://user-images.githubusercontent.com/46372998/212541682-9907aaea-5198-45a9-8961-2acc8a98a0db.png "Text displayed on hover")

[logo]: https://user-images.githubusercontent.com/46372998/212541682-9907aaea-5198-45a9-8961-2acc8a98a0db.png "Hover me"
![error text][logo]

---

## Links

Similar to images, links can also be inserted directly or by creating a reference. You can create both inline and block links.

```
[markdown-cheatsheet]: https://github.com/im-luka/markdown-cheatsheet
[docs]: https://github.com/adam-p/markdown-here

[Like it so far? Follow me on GitHub](https://github.com/im-luka)
[My Markdown Cheatsheet - star it if you like it][markdown-cheatsheet]
Find some great docs [here][docs]
```

[markdown-cheatsheet]: https://github.com/im-luka/markdown-cheatsheet
[docs]: https://github.com/adam-p/markdown-here

[Like it so far? Follow me on GitHub](https://github.com/im-luka)  
[My Markdown Cheatsheet - star it if you like it][markdown-cheatsheet]  
Find some great docs [here][docs]

---

## Code

You can cerate both inline and full block code snippets. You can also define programming language you were using in your snippet. All by using backticks.

```
    I created `.env` file at the root.
    Backticks inside backticks? `` `No problem.` ``

    ```
    {
      learning: "Markdown",
      showing: "block code snippet"
    }
    ```

    ```js
    const x = "Block code snippet in JS";
    console.log(x);
    ```
```

I created `.env` file at the root.
Backticks inside backticks? `` `No problem.` ``

```
{
  learning: "Markdown",
  showing: "block code snippet"
}
```

```js
const x = "Block code snippet in JS";
console.log(x);
```

---

## Lists

As you can do in HTML, Markdown allows creating of both ordered and unordered lists.

### Ordered List

```
1. HTML
2. CSS
3. Javascript
4. React
7. I'm Frontend Dev now 👨🏼‍🎨
```

1. HTML
2. CSS
3. Javascript
4. React
7. I'm Frontend Dev now 👨🏼‍🎨

### Unordered List

```
- Node.js
+ Express
* Nest.js
- Learning Backend ⌛️
```

- Node.js
- Express
- Nest.js

- Learning Backend ⌛️

### Mixed List

You can also mix both of the lists and create sublists.  
**PS.** Try not to create lists deeper than two levels. It is the best practice.

```
1. Learn Basics
   1. HTML
   2. CSS
   7. Javascript
2. Learn One Framework
   - React 
     - Router
     - Redux
   * Vue
   + Svelte
```

1. Learn Basics
   1. HTML
   2. CSS
   7. Javascript
2. Learn One Framework
   - React
     - Router
     - Redux
   - Vue
   - Svelte

---

## Table

Great way to display well-arranged data. Use "|" symbol to separate columns and ":" symbol to align row content.

```
| Left Align (default) | Center Align | Right Align |
| :------------------- | :----------: | ----------: |
| React.js             | Node.js      | MySQL       |
| Next.js              | Express      | MongoDB     |
| Vue.js               | Nest.js      | Redis       |
```

| Left Align (default) | Center Align | Right Align |
| :------------------- | :----------: | ----------: |
| React.js             | Node.js      | MySQL       |
| Next.js              | Express      | MongoDB     |
| Vue.js               | Nest.js      | Redis       |

---

## Task List

Keeping track of the tasks that are done, and those that need to be done.

```
- [x] Learn Markdown
- [ ] Learn Frontend Development
- [ ] Learn Full Stack Development
```

- [x] Learn Markdown
- [ ] Learn Frontend Development
- [ ] Learn Full Stack Development

---

## Footnote

Want to describe something at the end of the file? Use footnote!

```
#### I am working on a new project. [^1]
[^1]: Stack is: React, Typescript, Tailwind CSS  

Project is about music & movies.

##### Hope you will like it. [^see]
[^see]: Loading... ⌛️
```

#### I am working on a new project. [^1]

[^1]: Stack is: React, Typescript, Tailwind CSS  

Project is about music & movies.

##### Hope you will like it. [^see]

[^see]: Loading... ⌛️

---

## Jump to section

You can give ID to a section so that you can jump straight to that part of the file from wherever you are.

```
[Jump to a section with custom ID](#some-id)

...


##### Section with some ID
```

[Jump to a section with custom ID](#some-id)

---

## Horizontal Line

You can use asterisks, hyphens or underlines (*, -, _) to create horizontal line.  
The only rule is that you must include at least three chars of the symbol.

```
First Horizontal Line

***

Second One

-----

Third

_________
```

First Horizontal Line

***

Second One

-----

Third

_________

---

## HTML

You can also use raw HTML in your Markdown file. Most of the times that will work well, but sometimes you can experience some differences that you are not used to when working with standard HTML. Using CSS will not work.

```
<h1>This is a heading</h1>
<p>Paragraph...</p>

<hr />

<img src="auto-generated-path-to-file-when-you-upload-image" width="200">
<a href="https://github.com/im-luka">Follow me on GitHub</a>

<br />
<br />

<p>Quick hack for <strong><em>centering image</em></strong>?</p>
<p align="center"><img src="auto-generated-path-to-file-when-you-upload-image" /></p>

<details>
  <summary>One more quick hack? 🎭</summary>
  
  → Easy  
  → And simple
</details>
```

<h1>This is a heading</h1>
<p>Paragraph...</p>

<hr />

<img src="https://user-images.githubusercontent.com/46372998/212544874-d0654588-82f7-44f2-bbfa-2bf85fd73854.png" width="200">
<a href="https://github.com/im-luka">Follow me on GitHub</a>

<br />
<br />

<p>Quick hack for <strong><em>centering image</em></strong>?</p>
<p align="center"><img src="https://user-images.githubusercontent.com/46372998/212544874-d0654588-82f7-44f2-bbfa-2bf85fd73854.png" width="200" /></p>

<details>
  <summary>One more quick hack? 🎭</summary>
  
  → Easy  
  → And simple
</details>

---

##### Section with some ID

![](http://i.imgur.com/IMTN5cy.png)  

## Hello, welcome to my tutorial for markdown. 👋

In this tutorial you will learn the most basics things about Markdown. 👩‍🏫👨‍🏫

- Spanish version available [here](https://github.com/LewisVo/Markdown-Tutorial/blob/master/Translation:Spanish.md) 🇪🇸.
- Portuguese version available [here](https://github.com/LewisVo/Markdown-Tutorial/blob/master/README_pt-BR.md) 🇵🇹.
- French version available [here](https://github.com/luongvo209/Markdown-Tutorial/blob/master/README_fr.md) 🇫🇷.

*******
Tables of contents  

 1. [What is Markdown?](#whatismarkdown)
 2. [Why use Markdown?](#why)
 3. [Tools for Markdown](#tools)
 4. [Markdown Syntax](#syntax)

*******

<div id='whatismarkdown'/>  

## What is markdown ?  

According to Wikipedia :  

  >_Markdown is a lightweight markup language with plain text formatting syntax designed so that it can be converted to HTML and many other formats using a tool by the same name. Markdown is often used to format readme files, for writing messages in online discussion forums, and to create rich text using a plain text editor._

`SIMPLY: IT'S JUST ANOTHER TYPE OF TEXT FILE, LIKE .txt .doc ....( now it's .md :laughing:) AND IT HAS SOME SPECIAL SYNTAX.`  
<div id='why'/>  

_There is no clearly defined Markdown standard. This has led to fragmentation as different vendors write their own variants of the language to correct flaws or add missing features.. A list of markdown flavour is available [here](https://github.com/jgm/CommonMark/wiki/Markdown-Flavors)._

From now, this guide will mainly focus on Github Flavoured Markdown.

## Why use markdown?

Because it's :

- **EZ** : The syntax is so easy that you can learn in a minute or two then write without noticing anything weirdo  or geeky.
- **FAST** : It saves time compared to other types of text files/formats. It helps boost the productivity and workflows of writer.
- **CLEAN** : Both the syntax and output are clean, not messy with our eyes and simple to manage.
- **FLEXIBLE** : With just a little set-up, your text will be translated cross any platform out there, editable in any text-editing software and convertible to a wide array of formats.
<br></br>
**In short**, normal users will find it useful in any cases, especially when you are in need of something better than plain text but less functional than Microsoft Word.  
**For Developers**, if you are lazy to write HTML code , you will love markdown. **Moreover**, **Github** and many sites favor markdown for readme file of projects. That means you gonna meet markdown in your life one way or another.  

<div id='tools'/>  

## Tools for markdown

As said above, any editors can be used to edit markdown. However, there are a few tools that may be useful for you when it comes to edit markdown.

- **[_Stackedit_](https://stackedit.io)** : Ok, you can stop reading right now. Click the link then start your markdown tour in an eziest way ever. Just type normal text then use your mouse, click click done. You dont have to know the syntax.  It's good, but it will make you reliant and most developers prefers keyboards.
- **[_Dillinger_](http://dillinger.io/)** : Online tool, support live view (split screen) and export to html. Nothing too special but very neat and handy.
- **[_Typora_](https://www.typora.io/)** : Available for Mac and Windows, minimal, distraction free, live view seemlessly, bundled with a lot of other stuffs like Images, Lists, Tables, Code Fences, Math Blocks, YAML, Front Matters,Toc,...
- **[_Atom_](https://atom.io/)** : popular hackable text editor (you may be using this). Yeah, this is versatile. Markdown Support? Just a part of it but is greatly built in.
- **[_Minimalist Markdown_](https://chrome.google.com/webstore/detail/minimalist-markdown-edito/pghodfjepegmciihfhdipmimghiakcjf?hl=en)** : Chrome app. Works everywhere if you have Chrome installed ( this is my favorite one).
- **[_Macdown_](http://macdown.uranusjr.com/)** : best for Mac.
- **[_MarkdownPad_](http://markdownpad.com/)** : best for Windows.
- **[_Remarkable_](https://remarkableapp.github.io/)** : best for Linux.
- **[_GITBOOK_](http://www.gitbook.com/)** : GitBook is a modern publishing toolchain. Making both writing and collaboration easy. It does both support Markdown and have a close relation with the beloved Github.

<div id='syntax'/>  

## Markdown Syntax  

All Syntax can be found [here](https://daringfireball.net/projects/markdown/syntax) . It would take a lot of effort to describe syntax in text (they will be formatted) so please consider this table below for the whole basics syntax.  

| Format        | Syntax      | Example |
| ------|-----|-----|
| Italic   | \*Text\*  | _This is italic_  |
| Bold   | \*\*Bold\*\*  | **This is bold**  |
| Inline links  | \[Description text\](url here)  | A [link](http://www.github.com)  |
| Images  | \![Caption\](url to img)  | An image ![image](http://i.imgur.com/hRLuez2.png)  |
| Link+images  | \[\![Caption\](url to img)\](url to a page)\]  | Click me [![me](http://i.imgur.com/hRLuez2.png)](https://www.youtube.com)  |
| Footnotes   | I have more \[^1\] to say.   \[^1\]: say it down here.  | <a href="#section1">Hey,Please read the note below this table.   |
| Line breaks  | Double space + enter  |   |
| Unordered Lists  | \* Item1     \*Item 2  | <ul><li>item1</li><li>item2</li><li>item3</li><li>item4</li></ul>  |
| Ordered Lists  | 1. Item a    2. Item b  | <ol><li>itema</li><li>itemb</li><li>itemc</li><li>itemd</li></ol>   |
| Mixed Lists  | 1. Item 1      * item 1a  |  <ol><li>itema</li></ol><ul><li> item1</li></ul> |
| Block quote  | \> Quoted text  |  <blockquote>Stay Hungry Stay Foolish</blockquote>  |
| Preformatted  | Begin each line with,two spaces or more to,make text look,e x a c t l y,like,you,type i,t.  |   Begin each line with,two spaces or more to,make text look,e x a c t l y,like,you,type i,t.  |
| Code  | \`Insert Code\`  | `cout<<"Hello world";`  |
| Code block/ Syntax highlighting  | \`\`\`insert code\`\`\`  |  <a href="#section1">Hey,Please read the note below this table.  |
| Headers  | \#, \##, \###, \####, \#####, \###### (from h1 to h6)  |  <h3>This is a h3 header</h3> |
| Strike through  | \~~Insert text here\~~  | ~~I am dead~~  |
| Tables  | \| Tables   \|      Are      \|  Cool \| \|\----------\|\:\-------------\:\|------\:\| \| col 1 is\|  left-aligned \| $1600 \| | ![](http://i.imgur.com/EItt7mh.png) |
|Footnotes| Footnote[\^1\] <br> [\^1\]: Text reference | Here is a simple footnote[^1]. With some additional text after it. |

<br></br>
 <br></br>
 <p id="section1">Note: **Footnote** actually doesnt render properly in table, but it kinda looks like this </p>  

 ![](http://i.imgur.com/pmeBr28.png)  
   <br></br>
   The same goes for **block code/syntax hightlighting**. It kinda looks like this picture :
  
![](http://i.imgur.com/z8KrxAz.png).

These characteristics are dependent upon each markdown flavour.  

## Useful notes

- Markdown allows you to use backslash escapes to generate literal characters which
would otherwise have special meaning in Markdown’s formatting syntax. One commonly used backslash escape character is : \
 `So? \*This\* isnt italic  anymore but is surrounded by literal asterisks.`

- Youtube videos require some additional work.

  ```
  They can't be added directly but you can add an image with a link to the video like this:
  <a href="http://www.youtube.com/watch?feature=player_embedded&v=YOUTUBE_VIDEO_ID_HERE
  " target="_blank"><img src="http://img.youtube.com/vi/YOUTUBE_VIDEO_ID_HERE/0.jpg" 
  alt="IMAGE ALT TEXT HERE" width="240" height="180" border="10" /></a>
  ```

- Markdown does support Emojii :laughing: :laughing: :kissing_heart: :innocent: :green_heart: ( get some emojies [here](http://www.emoji-cheat-sheet.com/) )
- You can use \<br/> tag to force line break.
- Double space then enter if you want to make a new line if there is trouble making new lines.
- Seeing is not as good as practicing. You can either create a markdown file for yourself to practice or do it online [here](http://www.markdowntutorial.com).
- Footnotes and syntax highlighting are not part of the original markdown and are only supported by certain flavors of markdown (Feedback from [Sean Brody](https://goo.gl/ASZwEn))
- Any URL (like <http://www.github.com/>) will be automatically converted into a clickable link.  
- Markdown table support is designed to handle most tables for most people; it doesn’t cover all tables for all people. If you need complex tables you will need to create them by hand or with a tool specifically designed for your output format.
- Using image and links, you can create some colorful assets at render time. Badges like this are typical examples that you can find all over Github  [![Java](https://img.shields.io/badge/Java-%23FFac45.svg?&style=for-the-badge&logo=java&logoColor=white&color=yellow)](https://github.com/)  [![HTML](https://img.shields.io/badge/HTML-%23FFac45.svg?&style=for-the-badge&logo=html5&logoColor=white&color=orange)](https://github.com/)
[![CSS](https://img.shields.io/badge/CSS-%23FFac45.svg?&style=for-the-badge&logo=css3&logoColor=white&color=blue)](https://github.com/)
[![JavaScript](https://img.shields.io/badge/JAVASCRIPT-%23FFac45.svg?&style=for-the-badge&logo=javascript&logoColor=white&color=yellow)](https://github.com/)
[![Linkedin](https://img.shields.io/badge/linkedin-%230077B5.svg?&style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/)
[![Github](http://img.shields.io/badge/github-%231877F2.svg?&style=for-the-badge&logo=github&logoColor=white&color=black)](https://github.com/)
( get some badges [here](https://shields.io/) )

- Using code block syntax with diff language to generate colored text. There are still some limitations such as can not style the text inside and few colors. This can be applicable when you want to highlight some note or to show difference between two code block

```diff
- text in red
+ text in green
! text in orange
# text in gray
@@ text in purple (and bold)@@
```

- Add beautiful note or warning section into markdown GitHub:

> **Note**:

> **Warning**:

- In markdown file on Github, with code block syntax and Mermaid language specifed, we can draw many kinds of diagram. More syntax and sample diagrams [here](https://mermaid-js.github.io/)

  - Class diagram

   ```mermaid
   classDiagram
       class Duck{
        -weight
         +swim()
         +quack()
       }
   ```

  - Sequence diagram

   ```mermaid
   sequenceDiagram
       participant dotcom
       participant iframe
       dotcom->>iframe: loads html w/ iframe url
   ```

  - Flowchart

   ```mermaid
     graph TD;
         A-->B;
         A-->C;
         B-->D;
         C-->D;
   ```

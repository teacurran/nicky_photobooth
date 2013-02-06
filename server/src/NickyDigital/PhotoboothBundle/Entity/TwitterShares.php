<?php

namespace NickyDigital\PhotoboothBundle\Entity;

use Doctrine\ORM\Mapping as ORM;
use Gedmo\Mapping\Annotation as Gedmo;

/**
 * TwitterShares
 *
 * @ORM\Table()
 * @ORM\Entity
 */
class TwitterShares
{
	/**
	 * @var integer
	 *
	 * @ORM\Column(name="id", type="integer")
	 * @ORM\Id
	 * @ORM\GeneratedValue(strategy="AUTO")
	 */
	private $id;

	/**
	 * @ORM\ManyToOne(targetEntity="Photo", inversedBy="twitterShares")
	 */
	private $photo;

	// TODO: figure out why Timestampable isn't populating
	/**
	 * @var created $created
	 *
	 * @Gedmo\Timestampable(on="create")
	 * @ORM\Column(type="datetime", nullable=true)
	 */
	protected $created;

	// TODO: figure out why Timestampable isn't populating
	/**
	 * @var dateSent $updated
	 *
	 * @ORM\Column(type="datetime", nullable=true)
	 */
	protected $dateSent;

	/**
	 * @param \NickyDigital\PhotoboothBundle\Entity\created $created
	 */
	public function setCreated($created)
	{
		$this->created = $created;
	}

	/**
	 * @return \NickyDigital\PhotoboothBundle\Entity\created
	 */
	public function getCreated()
	{
		return $this->created;
	}

	/**
	 * @param \NickyDigital\PhotoboothBundle\Entity\dateSent $dateSent
	 */
	public function setDateSent($dateSent)
	{
		$this->dateSent = $dateSent;
	}

	/**
	 * @return \NickyDigital\PhotoboothBundle\Entity\dateSent
	 */
	public function getDateSent()
	{
		return $this->dateSent;
	}

	/**
	 * @param int $id
	 */
	public function setId($id)
	{
		$this->id = $id;
	}

	/**
	 * @return int
	 */
	public function getId()
	{
		return $this->id;
	}

	public function setPhoto($photo)
	{
		$this->photo = $photo;
	}

	public function getPhoto()
	{
		return $this->photo;
	}


}

/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('permiso_navegacion', {
		id_permiso_navegacion: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_permiso_navegacion::regclass)",
			primaryKey: true
		},
		lugar_emision: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fecha_emision: {
			type: DataTypes.DATE,
			allowNull: true
		},
		puerto_salida: {
			type: DataTypes.STRING,
			allowNull: true
		},
		puerto_llegada: {
			type: DataTypes.STRING,
			allowNull: true
		},
		mercancias: {
			type: DataTypes.STRING,
			allowNull: true
		},
		autoridad: {
			type: DataTypes.STRING,
			allowNull: true
		},
		observacion: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_navegacion_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'navegacion',
				key: 'id_navegacion'
			}
		}
	}, {
		tableName: 'permiso_navegacion',
		timestamps: false
	});
};
